source("/common/lir2lab/Olivia/Model-Evaluation/code/MethodEval.R")

args <- commandArgs(trailingOnly = TRUE)
betas_dir <- args[1]
    #format: betas_dir <- paste0("/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/", pheno, "/rep", rep, "/betas/")
gwas <- args[2]
    # format_line1: sumstats_dir <- paste0("/common/lir2lab/Olivia/sumstats_hapmap3/", pheno, "/rep", rep, "/")
    # format_line2: gwas <- paste0(sumstats_dir, pheno, "_rep", rep, "_chr", chr, "_gwas.txt")
genotype <- args[3]
    # format_line1: geno_prefix <- "/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr"
    # format_line2: genotype <- paste0(geno_prefix, chr)
n_gwas <- args[4]
chr <- args[5]

#ld_panel <- "/common/lir2lab/Okan/PRSCS/Codes/ldblk_ukbb_eur"
ld_panel <- "/common/lir2lab/Olivia/Model-Evaluation/ldpanel/ldblk_1kg_eur"
prscs_dir <- "/common/lir2lab/PRScs/"

if (!dir.exists(betas_dir)) {dir.create(betas_dir, recursive = TRUE)}
print(n_gwas)
prscs_args <- list(prscs_dir=prscs_dir,
                    ld_ref=ld_panel, 
                    bim_prefix= genotype,
                    gwas = gwas, 
                    n_gwas = n_gwas, 
                    chrom = as.numeric(chr),
                    output_dir = betas_dir)
do.call(PRScs, prscs_args)