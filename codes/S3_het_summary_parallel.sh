#!/usr/bin/env bash
# Summarize per-site heterozygosity across samples from a VCF.
# Output: *_het_summary.tsv (CHROM, POS, ID, NUM_HET, PCT_HET)

parallel -j 16 "mkdir -p het_summaries; \
awk -F'\t' 'BEGIN { OFS=\"\t\"; print \"CHROM\", \"POS\", \"ID\", \"NUM_HET\", \"PCT_HET\" } \
/^#/ { next } \
{ chrom=\$1; pos=\$2; id=\$3; n_het=0; n_samples=0; \
  for (i=10; i<=NF; i++) { if (\$i ~ /^0\/1/ || \$i ~ /^1\/0/) n_het++; n_samples++; } \
  pct_het=(n_het/n_samples)*100; \
  printf \"%s\t%s\t%s\t%d\t%.2f%%\\n\", chrom, pos, id, n_het, pct_het; }' {} \
> het_summaries/{/.}.het_summary.tsv" ::: /path/*.vcf
