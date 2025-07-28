source("/common/lir2lab/Olivia/Model-Evaluation/code/MethodEval.R")

args <- commandArgs(trailingOnly = TRUE)
betas_dir <- args[1]
gwas <- args[2]
genotype <- args[3]
n_gwas <- args[4]
chr <- args[5]
ld_panel <- args[6]
prscs_dir <- args[7]

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