#!/bin/bash

parallel -j 16 -a scaffold_ID_No.txt \
'awk -v c="scaffold_{}" '\''BEGIN{OFS="\t"} /^#/ {print > (c".vcf")} !/^#/ && $1 == c {print > (c".vcf")}'\'' /path/to/VCF/corrected_pos.vcf'

mkdir splitted_scaffolds
mv *.vcf splitted_scaffolds
