#!/usr/bin/env bash
# S6_multi_to_bi.sh
# Convert multi-allelic VCF records to biallelic by keeping the two most
# frequent alleles per site. Processes multiple VCF files in parallel using
# GNU parallel.
# Usage: S6_multi_to_bi.sh file1.vcf file2.vcf ...
# Output files are written to biallelic_vcfs/<basename>_biallelic.vcf

set -euo pipefail

convert() {
  in_vcf="$1"
  base=$(basename "${in_vcf}" .vcf)
  out_vcf="biallelic_vcfs/${base}_biallelic.vcf"

  python3 - "$in_vcf" "$out_vcf" <<'PYCODE'
import sys
from collections import Counter

def parse_genotypes(allele_strs):
    return allele_strs.replace('|', '/').split('/') if '.' not in allele_strs else []

def extract_alleles(ref, alt):
    return [ref] + alt.split(',')

def get_allele_counts(geno_list):
    counts = Counter()
    for g in geno_list:
        if g.startswith('./.') or '.' in g:
            continue
        alleles = parse_genotypes(g.split(':')[0])
        for a in alleles:
            counts[a] += 1
    return counts

def filter_to_top_two(line):
    cols = line.strip().split('\t')
    ref, alt = cols[3], cols[4]
    all_alleles = extract_alleles(ref, alt)
    sample_data = cols[9:]
    counts = get_allele_counts(sample_data)

    if len(all_alleles) <= 2:
        return line

    top_two = [x[0] for x in counts.most_common(2)]
    if '0' not in top_two:
        top_two.append('0')
        if len(top_two) > 2:
            least = min(top_two, key=lambda k: counts.get(k, 0))
            top_two.remove(least)

    format_fields = cols[8].split(':')
    gt_idx = format_fields.index('GT')

    new_samples = []
    for s in sample_data:
        parts = s.split(':')
        if len(parts) <= gt_idx:
            new_samples.append(s)
            continue
        alleles = parse_genotypes(parts[gt_idx])
        if not alleles or any(a not in top_two for a in alleles):
            parts[gt_idx] = './.'
        new_samples.append(':'.join(parts))

    alt_indices = [int(i) for i in top_two if i != '0']
    new_alt = ','.join([alt.split(',')[i - 1] for i in sorted(alt_indices)]) if alt_indices else '.'
    cols[4] = new_alt
    cols[9:] = new_samples
    return '\t'.join(cols) + '\n'

in_path, out_path = sys.argv[1], sys.argv[2]

with open(in_path) as fin, open(out_path, 'w') as fout:
    for line in fin:
        if line.startswith('#'):
            fout.write(line)
        else:
            fout.write(filter_to_top_two(line))
PYCODE
  echo "Converted ${in_vcf} -> ${out_vcf}"
}

export -f convert
mkdir -p biallelic_vcfs
parallel -j 16 convert ::: "$@"
