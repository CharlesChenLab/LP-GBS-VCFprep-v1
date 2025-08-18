import csv
from collections import defaultdict, Counter

vcf_file = "scaffold1_tworules.vcf"  # change this
scaffolds = [f"scaffold_{i}" for i in range(1, 2)]
#scaffolds = [f"scaffold_{i}" for i in [27, 31, 44,186,528]]
# Get the header line
with open(vcf_file) as f:
    for line in f:
        if line.startswith("#CHROM"):
            header = line.strip().split("\t")
            break

# Process one scaffold at a time
for scaffold in scaffolds:
    print(f"Processing {scaffold}...")
    pos_lines = defaultdict(list)

    # First pass: collect only duplicated positions for this scaffold
    with open(vcf_file) as f:
        for line in f:
            if line.startswith("#"):
                continue
            fields = line.strip().split("\t")
            if fields[0] != scaffold:
                continue
            pos = fields[1]
            pos_lines[pos].append(fields)

    # Get positions with >1 entry (duplicates)
    dup_pos = [pos for pos, vals in pos_lines.items() if len(vals) > 1]
    if not dup_pos:
        print(f"⚠️ No duplicated sites in {scaffold}")
        continue

    out_file = f"{scaffold}_allele_frequencies.csv"
    with open(out_file, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["CHROM", "POS", "REF", "ALT", "Total Alleles", "Allele Frequencies"])

        for pos in dup_pos:
            for row in pos_lines[pos]:
                ref = row[3]
                alts = row[4].split(",")
                allele_map = {str(i): allele for i, allele in enumerate([ref] + alts)}

                genos = row[9:]
                allele_counts = Counter()
                total = 0

                for gt_field in genos:
                    gt = gt_field.split(":")[0]
                    if gt in (".", "./.", ".|."):
                        continue
                    for a in gt.replace("|", "/").split("/"):
                        if a in allele_map:
                            allele_counts[allele_map[a]] += 1
                            total += 1

                if total == 0:
                    freq_str = "NA"
                else:
                    freq_str = ", ".join(f"{allele}: {allele_counts[allele] / total * 100:.1f}%" for allele in allele_counts)

                writer.writerow([scaffold, pos, ref, row[4], total, freq_str])

    print(f"✅ Done: {out_file}")

