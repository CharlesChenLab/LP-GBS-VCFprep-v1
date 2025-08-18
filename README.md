# Lodgepole pine VCF data cleaning and filtering workflow
This guide documents a reproducible pipeline to preprocess lodgepole pine (LP) GBS VCFs so they’re ready for GWAS and other downstream analyses. It includes coordinate correction, QC, duplicate handling, biallelic conversion, trait-based sample filtering, and missingness summaries. Optional phasing/imputation can be run at the end.

Toolchain: bcftools, awk, python3 (+ cyvcf2 for one script)
For detailed workflow steps, see the project ([wiki](https://github.com/ArghavanAlisoltani/LP-GBS-VCFprep/wiki)).
