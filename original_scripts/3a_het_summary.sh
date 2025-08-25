awk -F'\t' '
BEGIN {
  OFS = "\t";
  print "CHROM", "POS", "ID", "NUM_HET", "PCT_HET";
}
# Skip header
/^#/ { next }

{
  chrom = $1;
  pos = $2;
  id = $3;
  n_het = 0;
  n_samples = 0;

  for (i = 10; i <= NF; i++) {
    if ($i ~ /^0\/1/ || $i ~ /^1\/0/) n_het++;
    n_samples++;
  }

  pct_het = (n_het / n_samples) * 100;
  printf "%s\t%s\t%s\t%d\t%.2f%%\n", chrom, pos, id, n_het, pct_het;
}' /scratch/arghavan/LP/vcf_v1/Aria_processed/S2_split/splitted_scaffolds/scaffold_528.vcf > testS528/het_summary_S528.tsv

