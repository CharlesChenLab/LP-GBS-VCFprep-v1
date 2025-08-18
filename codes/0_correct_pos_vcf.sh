awk -F'\t' '
BEGIN { OFS="\t" }
# Keep header lines unchanged
/^#/ { print; next }

# For data lines
{
  # Extract true position from SNP ID
  split($3, id_parts, "_")
  true_pos = id_parts[3]
  $2 = true_pos   # Replace POS column
  print
}' GBStags_to_Lpine.merged.scaffold.final.vcf >corrected_pos.vcf 
