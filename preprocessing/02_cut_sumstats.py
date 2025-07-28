import pandas as pd

pheno = "cholesterol"

# Path to your GWAS file
#gwas_path = '/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/without_UKB_HDL_INV_EUR_HRC_1KGP3_others_ALL.meta.singlevar.results'
#gwas_path = '/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/without_UKB_LDL_INV_EUR_HRC_1KGP3_others_ALL.meta.singlevar.results'
gwas_path = '/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/without_UKB_TC_INV_EUR_HRC_1KGP3_others_ALL.meta.singlevar.results'
gwas = pd.read_csv(gwas_path, sep='\t')

# Column renaming map
rename_dict = {
    'rsID': 'SNP',
    'POS_b37': 'POS',
    'EFFECT_SIZE': 'BETA',
    'REF': 'A2',
    'ALT': 'A1',
    'N_studies': 'neff'
}
gwas = gwas.rename(columns=rename_dict)

for chr_num in range(1, 23):
    # Load SNP list for this chromosome
    with open(f'/common/lir2lab/Olivia/Model-Evaluation/consortium/result/snp_list/snp_list_chr{chr_num}.txt') as f:
        snps = set(line.strip() for line in f)
    # Filter GWAS for this chromosome and SNPs in LD panel
    chr_gwas = gwas[(gwas['CHROM'] == chr_num) & (gwas['SNP'].isin(snps))]
    # Output file
    out_path = f'/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/{pheno}/{pheno}_chr{chr_num}_gwas'
    chr_gwas.to_csv(out_path, sep='\t', index=False)
    print(f'Wrote {len(chr_gwas)} SNPs to {out_path}')
