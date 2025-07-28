library(data.table) #For fread
library(dplyr)
#library(bigsnpr) #For LDPred2
#source("/common/lir2lab/Olivia/Model-Evaluation/ukbb_scripts/prs_apply.R")
#source("/common/lir2lab/Olivia/Model-Evaluation/ukbb_scripts/Evaluation.R")

# Limitations/Conditions/Assumptions:
# 1) Output directory must have / at the end.
# 2) Remember to add dependencies
# Add combined boolean
# Don't forget to remove hardcoded optional arguments!
# File not found. if !file.exists -> careful of keep=""

prs_train <- function(genotype, phenotype, gwas, n_gwas, ld_panel, 
                       prsice_dir, prscs_dir, plink_dir, output_dir, 
                      binary, chrom="", pheno_name="", keep = "", exclude="",
                       snp="SNP", a1="A1", a2="A2", stat="OR", pvalue="P", se="SE", ...){
  
  ######### Step #1: Check Requirements ############
  
  # Helper function to ensure a directory ends with "/" if it exists
  check_directory <- function(directory, directory_name) {
    if (!dir.exists(directory)) {
      stop(directory_name, " does not exist.")
    } 
    if (!endsWith(directory, "/")) {
      directory <- paste0(directory, "/")
    }
    return(directory)
  }
  
  prsice_dir <- check_directory(prsice_dir, "PRSice Directory")
  prscs_dir <- check_directory(prscs_dir, "PRScs Directory")
  plink_dir <- check_directory(plink_dir, "PLINK Directory")
  if (!dir.exists(output_dir)) {dir.create(output_dir)}
  output_dir <- check_directory(output_dir, "Output Directory")

  # Create Sub-Directories for each method 
  prsice_out_dir = paste0(output_dir,"PRSice/")
  if (!dir.exists(prsice_out_dir)) {dir.create(prsice_out_dir)}
  prscs_out_dir = paste0(output_dir, "PRScs/")
  if (!dir.exists(prscs_out_dir)) {dir.create(prscs_out_dir)}
  plinkpt_out_dir = paste0(output_dir, "plinkPT/")
  if (!dir.exists(plinkpt_out_dir)) {dir.create(plinkpt_out_dir)}
  
  # Check header 
  #header <- read.table(gwas, header = TRUE, nrows = 1)
  #print(paste0("The header of the GWAS file is:", header))
  #prscs_gwas_ind <- sapply(c(snp, a1, a2, stat, se), function(col) which(colnames(header) == col))
  header <- strsplit(readLines(gwas, n = 1), split = "\\s+")[[1]]
  prscs_gwas_ind <- sapply(c(snp, a1, a2, stat, se), function(col) which(header == col))
  if(any(sapply(prscs_gwas_ind, function(x) identical(x, integer(0))))){stop("One of the required values (snp, a1, a2, stat, se) either does not match or is not present.")}
  plinkpt_gwas_ind <- sapply(c(snp, a1, stat), function(col) which(colnames(header) == col))

  ######### Step #2: Get arguments ################
  prsice_args <- list(prsice_dir=prsice_dir, 
                      output_dir=prsice_out_dir, 
                      prsice="PRSice_linux",
                      gwas=gwas, 
                      target_data=genotype, 
                      phenotype=phenotype, 
                      binary=binary,
                      chrom = chrom, pheno_name = pheno_name,
                      snp=snp, a1=a1, a2=a2, stat=stat, pvalue=pvalue)
  plinkpt_args <- list(plink_dir = plink_dir,
                       genotype = genotype,
                       gwas = gwas,
                       output_dir = plinkpt_out_dir,
                       chrom=chrom, pheno_name = pheno_name,
                       clump_p1 = 1, clump_p2=1, clump_r2=0.25, clump_kb=250)
  # PRScs Setup: Create a temporary gwas in designated format
  prscs_gwas_cols <- paste0("$", prscs_gwas_ind, collapse = ", ")
  #system(paste0("awk '{print ", prscs_gwas_cols, "}' ", gwas, "> ", prscs_out_dir, "temp_prscs_gwas.txt"))
  system(paste0("echo 'SNP A1 A2 OR SE' > ", prscs_out_dir, "temp_prscs_gwas.txt && ", 
                "awk 'NR > 1 {print ", prscs_gwas_cols, "}' ", gwas, " >> ", prscs_out_dir, "temp_prscs_gwas.txt"))
  prscs_args <- list(prscs_dir=prscs_dir,
                     ld_ref=ld_panel, 
                     bim_prefix= genotype,
                     gwas = paste0(prscs_out_dir, "temp_prscs_gwas.txt"), 
                     n_gwas = n_gwas, 
                     chrom = chrom,
                     output_dir = prscs_out_dir)
  
  if(is.character(keep) && keep != ""){
    prsice_args$keep = keep
    plinkpt_args$keep = keep
  }
  if(is.character(exclude) && exclude != ""){
    prsice_args$exclude = exclude
    plinkpt_args$exclude = exclude
  }

  ######### Step #3: Run Methods
  print("Starting PRSice...")
  do.call(PRSice, prsice_args)
  print("Starting PLINK P+T...")
  do.call(PLINKPT, plinkpt_args)
  print("Starting PRScs...")
  do.call(PRScs, prscs_args)
  system(paste0("rm ", prscs_out_dir, "temp_prscs_gwas.txt")) #remove temporary gwas file for prscs

  print("Training PRS Model Completed.")
}

prs_method_evaluation <- function(score_dir, phenotype, pheno_name, out_name="_Combined_Score.txt", binary){
  prsice <- fread(paste0(score_dir, pheno_name, "_PRSice", out_name),
                col.names = c("FID", "IID", "PRSice"))
  prscs <- fread(paste0(score_dir, pheno_name, "_PRScs", out_name),
                col.names = c("FID", "IID", "PRScs"))
  plinkpt <- fread(paste0(score_dir, pheno_name, "_PLINKPT", out_name),
                  col.names=c("FID", "IID", "PLINKPT"))
  pheno <- fread(phenotype, col.names=c("FID", "IID", "Phenotype"))
  ####DELETE AFTER##### (FOR BINARY AND THIS FILE ONLY)
  # pheno$Phenotype <- pheno$Phenotype-1

  #Merge pheno, prscs, prsice, plinkpt
  dataframes_to_merge <- list(pheno, prsice, prscs, plinkpt)
  all_scores <- Reduce(function(x, y) merge(x, y, by = c("FID", "IID")), dataframes_to_merge)
  filename=paste0(score_dir, pheno_name, "_Binary_Evaluation")

  model_evaluation(phenotype= as.matrix(all_scores[,3,drop=FALSE]),
                  PRScs = all_scores$PRScs,
                  PRSice = all_scores$PRSice,
                  "PLINK P+T" = all_scores$PLINKPT,
                  binary=binary,
                  bin=10, 
                  filename= filename)

  # Discarded Solution (To account for Continuous test/train regression)
  #if(binary){
  #  prsice <- fread(paste0(score_dir, "PRSice_Combined_Score.txt"),
  #                col.names = c("FID", "IID", "PRSice"))
  #  prscs <- fread(paste0(score_dir, "PRScs_Combined_Score.txt"),
  #               col.names = c("FID", "IID", "PRScs"))
  #  plinkpt <- fread(paste0(score_dir, "PLINKPT_Combined_Score.txt"),
  #                 col.names=c("FID", "IID", "PLINKPT"))
  #  pheno <- fread(phenotype, col.names=c("FID", "IID", "Phenotype"))

    #Merge pheno, prscs, prsice, plinkpt
  
  #  dataframes_to_merge <- list(pheno, prsice, prscs, plinkpt)
  #  all_scores <- Reduce(function(x, y) merge(x, y, by = c("FID", "IID")), dataframes_to_merge)
  #  filename=paste0(score_dir, disease, "_Binary_Evaluation")
  
  #}else{
   # all_scores <- fread(paste0(score_dir, disease, "_All_Regressed_Scores"), col.names=c("FID", "IID", "Phenotype", "PRScs", "PRSice", "PLINKPT"))
    #filename=paste0(score_dir, disease, "_Continuous_Evaluation")
  #}

  #model_evaluation(phenotype= as.matrix(all_scores[,3,drop=FALSE]),
  #                 PRScs = all_scores$PRScs,
  #                 PRSice = all_scores$PRSice,
  #                 "PLINK P+T" = all_scores$PLINKPT,
  #                 binary=binary,
  #                 bin=10, 
  #                 filename= filename)
}
  
PRSice <- function(prsice_dir, output_dir, prsice, gwas, target_data, phenotype, binary, chrom="", pheno_name, ...){
  
  #Retrieve Optional Inputs
  optional_list <- list(...)
  optional_call <- ""
  if (length(optional_list) != 0) {
    optional_names <- names(optional_list)
    for(i in 1:length(optional_list)){
      temp <- paste0(" --", optional_names[i], " ", optional_list[[i]])
      optional_call <- paste0(optional_call, temp)
    }
    print(optional_call)
  }

  # Run PRSice
  prsice_command <- paste0("Rscript ", prsice_dir, "PRSice.R --prsice ", prsice_dir, prsice, " --base ", gwas, 
                           " --target ", target_data, " --thread 1 --stat OR --binary-target ", binary, 
                           " --print-snp --out ", output_dir, pheno_name, "_prsice_chr", chrom, " --pheno ", phenotype, optional_call)
  print(prsice_command)
  system(prsice_command)
  
  print("PRSice Done.")
}

# Add stuff for only one input
PRScs <- function(prscs_dir, ld_ref, output_dir, gwas, n_gwas, bim_prefix, chrom="", ...){
  
  #Retrieve Optional Inputs
  optional_list <- list(...)
  if (length(optional_list) != 0) {
    optional_names <- names(optional_list)
    optional_call <- ""
    for(i in 1:length(optional_list)){
      temp <- paste0(" --", optional_names[i], "=", optional_list[[i]])
      optional_call <- paste0(optional_call, temp)
    }
    print(optional_call)
  }else{
    optional_call <- ""
  }
    print(chrom)
    print(as.numeric(chrom))
  if(as.numeric(chrom)%%1==0){
    optional_call <- paste0(optional_call, " --chrom=", chrom)
  }

  system(paste0("python ", prscs_dir, "PRScs.py --ref_dir=", ld_ref,
                " --bim_prefix=", bim_prefix, " --sst_file=", gwas,
                " --n_gwas=", format(n_gwas, scientific = FALSE),
                " --out_dir=", output_dir, optional_call))
  print("PRScs Done.")
}

PLINKPT <- function(plink_dir, genotype, gwas, output_dir,chrom="", pheno_name, gwas_ind = c(3, 4, 9),
                    clump_p1 = 0.0001, clump_p2=0.01, clump_r2=0.5, clump_kb=250, ...){
  
  #Retrieve Optional Inputs
  optional_list <- list(...)
  if (length(optional_list) != 0) {
    optional_names <- names(optional_list)
    optional_call <- ""
    for(i in 1:length(optional_list)){
      temp <- paste0(" --", optional_names[i], " ", optional_list[[i]])
      optional_call <- paste0(optional_call, temp)
    }
    print(optional_call)
  }else{
    optional_call <- ""
  }
  
  system(paste0(plink_dir, "plink2 --bfile ", genotype, " --clump-p1 ", clump_p1, " -clump-p2 ", 
                clump_p2, " --clump-r2 ", clump_r2, " --clump-kb ", clump_kb, " --clump ", gwas,
                " --out ", output_dir, pheno_name, "_plinkpt_chr", chrom, optional_call))
  print("PLINK P+T Done.")
}