import pandas as pd

pheno = "ad"

# Path to your GWAS file
gwas_path = '/common/lir2lab/Wanling/FDR_AB_PRS/External_PRS/consortium_GWAS/Kunkle_etal_Stage1_results.txt'
gwas = pd.read_csv(gwas_path, sep='\s+')

# Column renaming map
rename_dict = {
    'Chromosome': 'CHR',
    'Position': 'POS',
    'MarkerName': 'SNP',
    'Effect_allele': 'A1',
    'Non_Effect_allele': 'A2',
    'Beta': 'BETA',
}
gwas = gwas.rename(columns=rename_dict)

for chr_num in range(1, 23):
    # Load SNP list for this chromosome
    with open(f'/common/lir2lab/Olivia/Model-Evaluation/consortium/result/snp_list/snp_list_chr{chr_num}.txt') as f:
        snps = set(line.strip() for line in f)
    # Filter GWAS for this chromosome and SNPs in LD panel
    chr_gwas = gwas[(gwas['CHR'] == chr_num) & (gwas['SNP'].isin(snps))]
    # Output file
    out_path = f'/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/{pheno}/{pheno}_chr{chr_num}_gwas'
    chr_gwas.to_csv(out_path, sep='\t', index=False)
    print(f'Wrote {len(chr_gwas)} SNPs to {out_path}')
