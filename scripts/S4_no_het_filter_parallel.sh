# Run from the directory containing your *.vcf files
parallel -j 16 'mkdir -p het_filtered; \
python3 - "{}" > het_filtered/{/.}.het_filter.log 2>&1 <<'"'"'PY'"'"'
import pandas as pd
import sys, os

# keep the core logic; only make input/output flexible
vcf_file = sys.argv[1]  # path provided by GNU parallel placeholder {}
vcf_stem = os.path.basename(vcf_file)
vcf_stem = vcf_stem[:-4] if vcf_stem.lower().endswith(".vcf") else vcf_stem
output_file = os.path.join("het_filtered", f"{vcf_stem}_het_filtered.vcf")

def is_heterozygous(geno):
    return any(g not in {"0", "1", "2", "."} and g[0] != g[2] for g in geno if "/" in g or "|" in g)

with open(vcf_file, "r") as fin, open(output_file, "w") as fout:
    for line in fin:
        if line.startswith("#"):
            fout.write(line)
        else:
            fields = line.strip().split("\t")
            genotypes = fields[9:]
            # Extract only genotype strings (before any ':' like 0/1:...)
            gt_calls = [g.split(":")[0] for g in genotypes]
            if any("/" in g and g.split("/")[0] != g.split("/")[1] for g in gt_calls if g != "./."):
                fout.write(line)
PY
' ::: /path/to/vcfs/*.vcf
