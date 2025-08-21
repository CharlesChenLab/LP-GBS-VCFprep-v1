for i in {1..2}; do
  echo -e "\nscaffold_$i Duplicate Site Allele Frequencies:"
  awk -v chr="scaffold_$i" '
    BEGIN {OFS="\t"}
    $1 == chr && !/^#/ {
      pos_count[$2]++
      lines[$2][pos_count[$2]] = $0
    }
    END {
      for (pos in pos_count) {
        if (pos_count[pos] > 1) {
          for (j = 1; j <= pos_count[pos]; j++) {
            line = lines[pos][j]
            split(line, flds, "\t")
            ref = flds[4]
            split(flds[5], alts, ",")
            allele[0] = ref
            for (a = 1; a <= length(alts); a++) allele[a] = alts[a]
            delete counts
            total = 0

            for (k = 10; k <= length(flds); k++) {
              split(flds[k], g, ":")
              split(g[1], alleles, /[\/|]/)
              for (m in alleles) {
                idx = alleles[m]
                if (idx ~ /^[0-9]+$/ && idx in allele) {
                  counts[allele[idx]]++
                  total++
                }
              }
            }

            printf "%s\t%s\t%s\t%s\t", chr, pos, ref, flds[5]
            for (a in counts) {
              freq = 100 * counts[a] / total
              printf "%s: %.1f%% ", a, freq
            }
            print ""
          }
        }
      }
    }' GBStags_to_Lpine.merged.scaffold.final.missing50.vcf
done

