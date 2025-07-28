library(data.table)
library(ROCR)

args <- commandArgs(trailingOnly = TRUE)
pheno <- args[1]
#binary <- args[2]
phenotype_file <- args[2]
score_dir <- args[3]

print(paste0("Processing Phenotype ", pheno))

# 1. List all .sscore files in your directory
files <- list.files(score_dir, 
                    pattern = "score-chr([1-9]|1[0-9]|2[0-2])\\.sscore$", 
                    full.names = TRUE)

# 2. Read each file into a list
all_files <- lapply(files, fread)

# 3. Extract the PRS score columns (assuming columns 5 onward are scores)
# This assumes that the individuals are in the same order across files.
score_list <- lapply(all_files, function(dt) as.matrix(dt[, 5:ncol(dt)]))

# 4. Sum the score matrices element-wise across chromosomes
final_scores <- Reduce("+", score_list)
# Attach the first 4 columns (e.g., SNP info or ID columns) from the first file (assuming they're identical across files)
final_output <- cbind(all_files[[1]][, 1:4], final_scores)

# 5. Read phenotype file 
phenotype<-fread(phenotype_file)

# Ensure column names match before merging (assuming first two columns are fid and iid)
setnames(final_output, c("FID", "IID", "ALLELE_CT", "NAMED_ALLELE_DOSAGE_SUM", "PRS"))
setnames(phenotype, c("FID", "IID", "phenotype"))

# Merge by FID and IID
merged_data <- merge(final_output, phenotype, by = c("FID", "IID"))

write.table(merged_data, file = paste0(score_dir, 'plinkpt-sum.txt'),
            col.names = T,row.names = F,quote=F)

print(paste0("Score written in file ",  paste0(score_dir, 'plinkpt-sum.txt')))