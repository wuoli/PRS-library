#!/bin/bash

# Define the GWAS file and output directory
GWAS_FILE="/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/SNP_gwas_mc_merge_nogc.tbl.uniq"
OUTPUT_DIR="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/bmi/"

# Loop through the 22 SNP list files
for i in {1..22}
do
    SNP_LIST_FILE="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/snp_list/snp_list_chr${i}.txt"
    OUTPUT_FILE="${OUTPUT_DIR}bmi_chr${i}_gwas"

    # Extract the header, replace column names, and write to output
    head -1 "$GWAS_FILE" | sed 's/\<b\>/BETA/g; s/\<se\>/SE/g' > "$OUTPUT_FILE"
    
    # Extract SNPs from the GWAS file that match the SNP list and append to output
    grep -wFf "$SNP_LIST_FILE" "$GWAS_FILE" | tail -n +2 >> "$OUTPUT_FILE"
done
