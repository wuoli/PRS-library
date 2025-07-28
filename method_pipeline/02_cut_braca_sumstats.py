import pandas as pd
import os

# Paths and constants
target_file = '/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/CIMBA_BRCA1_BCAC_TN_meta_summary_level_statistics.txt'
ref_base = '/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/breast_cancer/rep1/ADD'
output_dir = '/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/breast_cancer'
os.makedirs(output_dir, exist_ok=True)

# Read target once
target_df = pd.read_csv(target_file, sep=',')

for chr_num in range(1, 23):
    # Build file paths
    ref_file = f'{ref_base}/breast_cancer_chr{chr_num}_gwas_add'
    output_file = f'{output_dir}/breast_cancer_chr{chr_num}_gwas'

    # Read and rename reference file
    ref_df = pd.read_csv(ref_file, sep='\s+', comment='#', header=None)
    ref_df.columns = ['CHROM', 'POS', 'SNP', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13']

    # Merge on chromosome and position
    merged_df = pd.merge(
        target_df,
        ref_df[['CHROM', 'POS', 'SNP']],
        left_on=['CHR', 'position'],
        right_on=['CHROM', 'POS'],
        how='inner'
    )

    # Rename and select relevant columns
    merged_df.rename(columns={'Allele1': 'A2', 'Allele2': 'A1', 'Effect': 'BETA', 'StdErr': 'SE'}, inplace=True)
    output_df = merged_df[['SNP', 'CHR', 'POS', 'A1', 'A2', 'BETA', 'SE', 'P-value', 'MarkerName', 'eff_freq', 'FreqSE']]

    # Save output
    output_df.to_csv(output_file, sep='\t', index=False)
