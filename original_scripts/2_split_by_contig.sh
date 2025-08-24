for i in $(seq 1 24); do
    contig="scaffold_$i"
    awk -v c="$contig" 'BEGIN{OFS="\t"} 
        /^#/ {print > (c".vcf")} 
        !/^#/ && $1 == c {print > (c".vcf")} 
    ' corrected_pos_full.vcf
done

