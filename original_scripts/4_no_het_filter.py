import pandas as pd

vcf_file = "/scratch/arghavan/LP/vcf_v1/Aria_processed/S2_split/splitted_scaffolds/scaffold_528.vcf"
output_file = "scaffold_528_het_filtered.vcf"

def is_heterozygous(geno):
    return any(g not in {"0", "1", "2", "."} and g[0] != g[2] for g in geno if "/" in g or "|" in g)

with open(vcf_file, 'r') as fin, open(output_file, 'w') as fout:
    for line in fin:
        if line.startswith("#"):
            fout.write(line)
        else:
            fields = line.strip().split('\t')
            genotypes = fields[9:]
            # Extract only genotype strings (before any ':' like 0/1:...)
            gt_calls = [g.split(':')[0] for g in genotypes]
            if any("/" in g and g.split("/")[0] != g.split("/")[1] for g in gt_calls if g != './.'):
                fout.write(line)

