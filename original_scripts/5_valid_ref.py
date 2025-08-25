valid_bases = {"A", "C", "G", "T"}

with open("scaffold_528_het_filtered.vcf", 'r') as fin, open("scaffold_528_het_ref_filtered.vcf", 'w') as fout:
    for line in fin:
        if line.startswith("#"):
            fout.write(line)
        else:
            ref = line.split('\t')[3]
            if ref in valid_bases:
                fout.write(line)

