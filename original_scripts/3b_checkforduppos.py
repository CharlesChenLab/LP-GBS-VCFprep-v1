from collections import defaultdict

vcf_file = "/scratch/arghavan/LP/vcf_v1/Aria_processed/S2_split/splitted_scaffolds/scaffold_528.vcf"
pos_count = defaultdict(int)

with open(vcf_file) as f:
    for line in f:
        if line.startswith("#"):
            continue
        chrom, pos = line.split("\t")[0:2]
        key = f"{chrom}:{pos}"
        pos_count[key] += 1

# Print duplicates
duplicates = {k: v for k, v in pos_count.items() if v > 1}
for k, v in duplicates.items():
    print(f"Duplicate at {k}, count: {v}")
