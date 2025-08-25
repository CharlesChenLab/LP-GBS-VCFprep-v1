from collections import defaultdict

def parse_genotype(gt_str):
    """Return 0 (hom), 1 (het), or None for missing."""
    if gt_str.startswith("./.") or "." in gt_str:
        return None
    alleles = gt_str.split(":")[0].replace("|", "/").split("/")
    if len(set(alleles)) == 1:
        return 0
    return 1

def heterozygosity(genotypes):
    valid = [g for g in genotypes if g is not None]
    if not valid:
        return 0.0
    hets = sum(1 for g in valid if g == 1)
    return hets / len(valid)

def is_biallelic(alt):
    return "," not in alt

vcf_in = "scaffold_528_biallelic_filtered.vcf"
vcf_out = "scaffold_528_tworules.vcf"

header = []
pos_dict = defaultdict(list)

with open(vcf_in) as f:
    for line in f:
        if line.startswith("#"):
            header.append(line)
            continue
        cols = line.strip().split("\t")
        chrom, pos, snp_id, ref, alt = cols[0], cols[1], cols[2], cols[3], cols[4]
        genotypes = [parse_genotype(gt) for gt in cols[9:]]
        het = heterozygosity(genotypes)
        biallelic = is_biallelic(alt)

        record = {
            "line": line,
            "chrom": chrom,
            "pos": pos,
            "snp_id": snp_id,
            "ref": ref,
            "alt": alt,
            "biallelic": biallelic,
            "het": het
        }
        pos_dict[(chrom, pos)].append(record)

final_records = []

for key, recs in pos_dict.items():
    if len(recs) == 1:
        final_records.append(recs[0]["line"])
    else:
        # Sort by highest heterozygosity first
        recs.sort(key=lambda r: (-r["het"], not r["biallelic"]))
        r1, r2 = recs[0], recs[1] if len(recs) > 1 else None

        if r1["biallelic"] and r2 and r2["biallelic"]:
            # Rule 1: both biallelic → keep one with higher het (already sorted)
            final_records.append(r1["line"])
        elif r2 and r1["het"] == r2["het"] and (r1["biallelic"] != r2["biallelic"]):
            # Rule 2: biallelic vs multiallelic with same het → keep biallelic
            final_records.append(r1["line"] if r1["biallelic"] else r2["line"])
        elif r1["biallelic"] is False and r2 and r2["biallelic"] is False:
            # Rule 3: both multiallelic → keep both
            final_records.extend([r1["line"], r2["line"]])
        else:
            # Default: keep highest het
            final_records.append(r1["line"])

# Write to output
with open(vcf_out, "w") as out:
    out.writelines(header)
    out.writelines(final_records)

