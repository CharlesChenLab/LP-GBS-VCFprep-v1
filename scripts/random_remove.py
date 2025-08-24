import random

vcf_in = "/scratch/sopal/LPpine/corrected_pine_data/tworules_filtered/scaffold_10_tworules.vcf"
vcf_out = "/scratch/sopal/LPpine/corrected_pine_data/tworules_filtered/scaffold_10_no_duplicate.vcf"

target_chrom = "scaffold_10"
target_pos = "859606154"

buffer = []
deleted = False

with open(vcf_in) as fin, open(vcf_out, "w") as fout:
    for line in fin:
        if line.startswith("#"):
            fout.write(line)
            continue

        cols = line.strip().split("\t")
        chrom = cols[0]
        pos = cols[1]

        if chrom == target_chrom and pos == target_pos:
            buffer.append(line)
        else:
            fout.write(line)

    # Randomly retain one variant at the duplicate POS
    if buffer:
        retained = random.choice(buffer)
        fout.write(retained)

