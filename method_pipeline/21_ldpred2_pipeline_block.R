#module load R/4.2.1
library(data.table)
library(dplyr)
library(bigsnpr)
library(bigreadr)
library(Matrix)

args <- commandArgs(trailingOnly = TRUE)
pheno <- args[1]
betas_dir <- args[2]
sumstats_dir <- args[3]
neff_dir <- args[4]
neff_column <- args[5]
neff_column <- as.numeric(neff_column)
NCORES <- nb_cores()
if (!dir.exists(betas_dir)) {dir.create(betas_dir, recursive=TRUE)}

parameters <- data.frame(matrix(ncol=6, nrow=0))
colnames(parameters) <- c("chr", "block", "h2_init", "h2_est", "p_init", "p_est")

for(chr in 1:22){
  print(paste0("Running Chromosome ", chr, "..."))

  sumstats <- bigreadr::fread2(input=paste0(sumstats_dir, pheno, "_chr", chr, "_gwas"), col.names=c("rsid", "a1", "a0", "beta", "beta_se"))
  if (!is.na(as.numeric(neff_dir))) {
    sumstats$n_eff <- rep(as.numeric(neff_dir), nrow(sumstats))
  } else {
    n_eff <- fread(paste0(neff_dir, pheno, "_chr", chr, "_gwas"), select = neff_column)
    sumstats$n_eff <- as.numeric(n_eff$N)
  }
  sumstats$chr <- rep(as.numeric(chr), nrow(sumstats))

  map_ldref <- fread("/common/lir2lab/Olivia/Model-Evaluation/ldpanel/ld_matrix_1kg/1000G_EUR_hm3_mega.map",
                     col.names=c("chr", "rsid","posg", "pos", "a1", "a0", "block", "ix"))
  df_beta <- snp_match(sumstats, map_ldref, join_by_pos = FALSE, match.min.prop=0.2)
  df_beta <- tidyr::drop_na(tibble::as_tibble(df_beta))

  corr_list <- readRDS(paste0("/common/lir2lab/Olivia/Model-Evaluation/ldpanel/ld_matrix_1kg/1000G_EUR_hm3_mega_chr", chr, "_ld.RDS"))

  chr_betas <- data.frame()
  for (b in unique(df_beta$block)) {
    print(paste0("Running block ", b, " in chromosome ", chr))

    snp_block <- df_beta[df_beta$block == b, ]
    idx <- snp_block$ix
    if (length(idx) == 0) next

    corr_block <- Matrix(corr_list[[b]][idx, idx], sparse=TRUE)
    corr_sub <- as_SFBM(corr_block, backingfile = tempfile(tmpdir = "/common/lir2lab/Olivia/LDPred2/ld_sfbm", fileext = paste0("_chr", chr, "_block", b)))

    ld <- Matrix::colSums(corr_block^2)
    ldsc <- with(snp_block, snp_ldsc(ld, ld_size=nrow(map_ldref), chi2 = (beta / beta_se)^2, sample_size = n_eff, ncores = NCORES))
    ldsc_h2_est <- abs(ldsc[["h2"]])

    coef_shrink <- 0.9

    multi_auto <- tryCatch({
      snp_ldpred2_auto(
        corr = corr_sub,
        df_beta = snp_block,
        h2_init = ldsc_h2_est,
        vec_p_init = 0.018,
        use_MLE = FALSE,
        ncores = NCORES,
        allow_jump_sign = TRUE,
        shrink_corr = coef_shrink
      )
    }, error = function(e) {
      print(paste("Error in multi_auto for phenotype", pheno, "block", b, ":", e$message))
      return(NULL)
    })

    if (is.null(multi_auto)) {
      print(paste0("Skipping block ", b, " due to error in multi_auto."))
    } else {
      beta_auto <- multi_auto[[1]]$beta_est
      result <- data.frame(snp_block[, c("chr", "rsid", "a1", "a0")], ldpred2_beta=beta_auto)
      chr_betas <- rbind(chr_betas, result)  

      parameters <- rbind(parameters, data.frame(
        chr = chr,
        block = b,
        h2_init = multi_auto[[1]]$h2_init,
        h2_est = multi_auto[[1]]$h2_est,
        p_init = multi_auto[[1]]$p_init,
        p_est = multi_auto[[1]]$p_est
      ))
    }
  }

  write.table(parameters, paste0(betas_dir, "parameters"), sep = "\t", row.names = FALSE, quote = FALSE)
  write.table(chr_betas, paste0(betas_dir, "chr", chr, "_betas"), sep = "\t", row.names = FALSE, quote = FALSE)
}
