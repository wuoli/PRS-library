import pandas as pd
import os

# Paths and constants
target_file = '/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/Mahajan.NatGenet2018b.T2D-noUKBB.European.txt'
ref_base = '/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/t2d/rep1/ADD'
output_dir = '/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats_prscs/t2d'
os.makedirs(output_dir, exist_ok=True)

# Read target once
target_df = pd.read_csv(target_file, sep='\s+')

for chr_num in range(1, 23):
    # Build file paths
    ref_file = f'{ref_base}/t2d_chr{chr_num}_gwas_add'
    output_file = f'{output_dir}/t2d_chr{chr_num}_gwas'

    # Read and rename reference file
    ref_df = pd.read_csv(ref_file, sep='\s+', comment='#', header=None)
    ref_df.columns = ['CHROM', 'POS', 'rsid', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13']

    # Merge on chromosome and position
    merged_df = pd.merge(
        target_df,
        ref_df[['CHROM', 'POS', 'rsid']],
        left_on=['Chr', 'Pos'],
        right_on=['CHROM', 'POS'],
        how='inner'
    )

    # Rename and select relevant columns
    merged_df.rename(columns={'EA': 'A1', 'NEA': 'A2', 'Beta': 'BETA'}, inplace=True)
    output_df = merged_df[['rsid', 'Chr', 'Pos', 'A1', 'A2', 'EAF', 'BETA', 'SE', 'Pvalue']]

    # Save output
    output_df.to_csv(output_file, sep='\t', index=False)
