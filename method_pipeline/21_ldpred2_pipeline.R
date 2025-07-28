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

##########################
# Step 0: Preprocessing  
##########################

parameters <- data.frame(matrix(ncol=4, nrow=22))
for(chr in 1:22){
    print(paste0("Running Chromosome ", chr, "..."))

    # Step 0.1 Load Summary Statistics
    sumstats <- bigreadr::fread2(input=paste0(sumstats_dir, pheno, "_chr", chr, "_gwas"), col.names=c("rsid", "a1", "a0", "beta", "beta_se"))
    if (!is.na(as.numeric(neff_dir))) {
        sumstats$n_eff <- rep(as.numeric(neff_dir), nrow(sumstats))
    } else {
        n_eff <- fread(paste0(neff_dir, pheno, "_chr", chr, "_gwas"), select = neff_column)
        sumstats$n_eff <- as.numeric(n_eff$N)
    }
    sumstats$chr <- rep(as.numeric(chr), nrow(sumstats))
    
    # Step 0.2 Load LD Matrix
    map_ldref <- readRDS("/common/lir2lab/Olivia/Model-Evaluation/ldpanel/bigsnpr_ldpanel_1kg_eur/ld_map.rds") #load map
    df_beta <- snp_match(sumstats, map_ldref, join_by_pos = FALSE, match.min.prop=0.2) #match snps
    (df_beta <- tidyr::drop_na(tibble::as_tibble(df_beta))) #drop NAs

    # Load to Sparse File Backed Matrix
    tmp <- tempfile(tmpdir = "/common/lir2lab/Olivia/LDPred2/ld_sfbm")

    valid_idx <- which(!is.na(df_beta$beta) & !is.na(df_beta$beta_se) & df_beta$beta_se > 0)
    chi2 <- (df_beta$beta[valid_idx] / df_beta$beta_se[valid_idx])^2
    print(paste0("Chi2 sample: ", head(chi2)))
   
    # Parse LD matrix and store as SFBM
    ind.chr2 <- df_beta$`_NUM_ID_`
    ind.chr3 <- match(ind.chr2, which(map_ldref$chr == chr))
    corr_chr <- readRDS(paste0("/common/lir2lab/Olivia/Model-Evaluation/ldpanel/bigsnpr_ldpanel_1kg_eur/ld_chr", chr, ".rds"))[ind.chr3, ind.chr3]
    #corr_chr <- readRDS(paste0("/common/lir2lab/Olivia/Model-Evaluation/ldpanel/bigsnpr_from_hdf5_1kg_eur/ldblk_1kg_chr", chr, ".rds"))[ind.chr3, ind.chr3]
    corr_chr2 <- as(corr_chr, "dsCMatrix")
    corr <- as_SFBM(corr_chr2, tmp)
    file.size(corr$sbk) / 1024^3 # file size in GB

    # Step 2: LDpred2-auto: automatic model
    ## Does not need a validation set bc directly infers values for hyper-parameters h2 and p
    # recommend run many chains in parallel w diff initial p values, used for qc afterwards
    # new parameters: allow_jump_sign, shrink_corr
    
    print("Checking df_beta for missing values:")
    print(colSums(is.na(df_beta)))
    print("Checking LD matrix:")
    print(str(df_beta))
    print("LD Size: ")
    print(nrow(map_ldref))

    # Step 2.1: Calculate h2 -> from args
        # Step 2.1: Calculate h2
    (ldsc <- with(df_beta, snp_ldsc(ld, ld_size=nrow(map_ldref), chi2 = chi2,
                                sample_size = n_eff, ncores = NCORES)))
    ldsc_h2_est <- abs(ldsc[["h2"]])

    # Step 2.2: Checking/Preparing Parameters :D 
    coef_shrink <- 0.9  # reduce this up to 0.4 if you have some (large) mismatch with the LD ref

    # Step 2.3: Run automatic model!
    multi_auto <- tryCatch({
    snp_ldpred2_auto(
        corr = corr, 
        df_beta = df_beta, 
        h2_init = ldsc_h2_est,
        vec_p_init = 0.018,
        use_MLE = FALSE,  
        ncores = NCORES, 
        allow_jump_sign = TRUE, 
        shrink_corr = coef_shrink
    )
    }, error = function(e) {
    # Catch the error and print a message
    print(paste("Error in multi_auto for phenotype", pheno, ":", e$message))
    return(NULL)  # Return NULL if there's an error
    })

    if (is.null(multi_auto)) {
        print("Skipping this chromosome due to an error in multi_auto.")
    } else {
        # Double check multi_auto:
        str(multi_auto, max.level = 1) #check multi_auto
        print("multi_auto initial p of 0.018")
        str(multi_auto[[1]], max.level = 1)

        #Check NAs
        print("check multi_auto NAs: ")
        multi_auto[[1]]$beta_est[is.na(multi_auto[[1]]$beta_est)]
        multi_auto[[1]]$corr_est[is.na(multi_auto[[1]]$corr_est)]

        beta_auto <- multi_auto[[1]]$beta_est

        result <- data.frame(df_beta[, c(1:4)], ldpred2_beta=beta_auto)

        if (!dir.exists(betas_dir)) {dir.create(betas_dir, recursive=TRUE)}
        write.table(result, paste0(betas_dir, "chr", chr, "_betas"), sep = "\t", row.names = FALSE, quote = FALSE)

        parameters$h2_init[chr] <- multi_auto[[1]]$h2_init
        parameters$h2_est[chr] <- multi_auto[[1]]$h2_est
        parameters$p_init[chr] <- multi_auto[[1]]$p_init
        parameters$p_est[chr] <- multi_auto[[1]]$p_est
        write.table(parameters, paste0(betas_dir, "parameters"), sep = "\t", row.names = FALSE, quote = FALSE)
    }
}
