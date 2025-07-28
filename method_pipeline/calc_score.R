# Read in arguments passed from command line
args <- commandArgs(trailingOnly = TRUE)

pheno <- args[1]
chr <- args[2]
phenotype_file <- args[3] 
betas_file <- args[4]
score_dir <- args[5]
geno_prefix <- args[6]

print(paste0("Processing Phenotype ", pheno, " chromosome ", chr))

if (!dir.exists(score_dir)) dir.create(score_dir, recursive=TRUE)

prscode <- paste(
    "/common/lir2lab/plink/plink2",
    paste0("--score ", betas_file, " 5 3 9"),
    "cols=+scoresums,-scoreavgs",
    paste0("--bfile ", geno_prefix),
    "--threads 1",
    paste0("--keep ", phenotype_file),
    paste0("--out ", score_dir, "prscs-chr", chr)
)

system(prscode)
print(paste0("Completed pheno ", pheno, " chr", chr))