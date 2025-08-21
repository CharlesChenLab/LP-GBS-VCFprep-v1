#!/usr/bin/ bash
# S1_vcf_set_pos_from_id.sh
# Update VCF POS column from the 3rd underscore-delimited token in the ID column.
# Usage:
#   S1_vcf_set_pos_from_id.sh <input.vcf|-> <output.vcf|->
# Examples:
#   S1_vcf_set_pos_from_id.sh input.vcf corrected.vcf
#   zcat input.vcf.gz | S1_vcf_set_pos_from_id.sh - corrected.vcf
#   S1_vcf_set_pos_from_id.sh input.vcf -   # writes to stdout


in="${1:-}"
out="${2:-}"

if [[ -z "${in}" || -z "${out}" ]]; then
  echo "Usage: $0 <input.vcf|-> <output.vcf|->" >&2
  exit 1
fi

# Allow stdin/stdout via "-"
[[ "$in"  == "-" ]] && in="/dev/stdin"
[[ "$out" == "-" ]] && out="/dev/stdout"

awk -F'\t' '
BEGIN { OFS="\t" }
# Keep header lines unchanged
/^#/ { print; next }

# For data lines
{
  # Extract true position from SNP ID (3rd field), assuming ID like: something_something_truePOS_...
  split($3, id_parts, "_")
  true_pos = id_parts[3]
  $2 = true_pos   # Replace POS column with the extracted value
  print
}
' "$in" > "$out"
