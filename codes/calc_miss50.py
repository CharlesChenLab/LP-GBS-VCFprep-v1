from cyvcf2 import VCF

vcf = VCF("scaffold1_no_duplicate.vcf")
threshold = 0.5
count = 0
num_samples = len(vcf.samples)

for variant in vcf:
    gt = variant.genotypes
    missing = sum(1 for g in gt if g[0] is None or g[1] is None)
    if missing / num_samples >= threshold:
        count += 1

print(f"Sites with >=50% missing genotypes: {count}")

