# Process all .vcf files under S4_filt_no_het/het_filtered (no .gz handling)
find S4_filt_no_het/het_filtered -type f -name '*.vcf' \
| parallel -j 16 'mkdir -p het_ref_filtered; \
python3 - "{}" > het_ref_filtered/{= s:.*/::; s:\.vcf$::; =}.het_ref_filter.log 2>&1 <<'"'"'PY'"'"'
import sys, os

# ---- flexible input / matched-name output ----
vcf_file = sys.argv[1]
stem = os.path.basename(vcf_file)

# drop .vcf
if stem.lower().endswith(".vcf"):
    stem = stem[:-4]

# remove trailing _het_filtered if present
if stem.endswith("_het_filtered"):
    stem = stem[: -len("_het_filtered")]

out_dir = "het_ref_filtered"
output_file = os.path.join(out_dir, f"{stem}_het_ref_filtered.vcf")

# keep your main logic; just add light guards for short lines
valid_bases = {"A", "C", "G", "T"}

with open(vcf_file, "r") as fin, open(output_file, "w") as fout:
    for line in fin:
        if not line:
            continue  # skip empty reads
        if line.startswith("#"):
            fout.write(line)
            continue
        parts = line.rstrip("\n\r").split("\t")
        if len(parts) < 4:  # guard against malformed lines
            continue
        ref = parts[3]
        if ref in valid_bases:
            fout.write(line)
PY'

