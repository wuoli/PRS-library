#!/bin/bash

cd /common/lir2lab/Olivia/Model-Evaluation/allele_diff

# Extract required columns from each file
awk '{print $3, $6}' /common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/AD_DNAnexus/rep1/ADD/AD_DNAnexus_chr22_gwas_add | sort -k1,1 > wanling.txt
awk '{print $2, $5, $6}' /common/lir2lab/Wanling/DATA/UKBB/Genotype/chr22.bim | sort -k1,1 > geno.txt
awk '{print $1, $2, $3}' /common/lir2lab/Olivia/sumstats_hapmap3/AD_DNAnexus/rep1/AD_DNAnexus_rep1_chr22_gwas.txt | sort -k1,1 > olivia.txt
awk '{print $1, $2}' /common/lir2lab/Olivia/LDPred2/betas5_hapmap/AD_DNAnexus/rep1/betas/chr22_betagrid | sort -k1,1 > ldpred.txt

# Find common SNPs across all files
join wanling.txt geno.txt > temp1
join temp1 olivia.txt > temp2
join temp2 ldpred.txt > combined.txt

# Add header and check A1 consistency
echo "SNP W.A1 geno.A1 geno.A2 O.A1 O.A2 beta.A1 A1_Match" > final_output.txt
awk '{
    match_status = "TRUE"
    if ($2 != $3 || $2 != $5 || $2 != $7) match_status = "FALSE"
    print $0, match_status
}' combined.txt >> final_output.txt

# Cleanup temporary files
rm wanling.txt geno.txt olivia.txt ldpred.txt temp1 temp2 combined.txt
