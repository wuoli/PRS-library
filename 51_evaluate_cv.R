library(data.table)
library(ROCR)

out_dir <- '/common/lir2lab/Olivia/Model-Evaluation/consortium/result/'
iid_base <- '/common/lir2lab/Wanling/FDR_AB_PRS/IID'
methods <- c('prscs', 'ldpred2', 'megaprs')
phenos <- c("t2d", "breast_cancer", "ad", "hypertension", "hdl", "ldl", "bmi", "cholesterol")
binaries <- c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE) 
reps <- 1:5

# Scoring functions
AUC_Score <- function(prs, pheno) {
  mod <- glm(pheno ~ PRS, data = prs, family = "binomial")
  pred <- prediction(predict(mod, prs, type = "response"), pheno)
  auc <- performance(pred, measure = "auc")@y.values[[1]]
  return(auc)
}

RSquared_Score <- function(prs, pheno) {
  mod <- lm(pheno ~ PRS, data = prs)
  r2 <- summary(mod)$r.squared
  return(r2)
}

# Initialize long format output
results <- data.table()

for (pheno_idx in seq_along(phenos)) {
  for (method in methods) {
  
    pheno <- phenos[pheno_idx]
    binary <- binaries[pheno_idx]

    for (rep in reps) {
      score_file <- file.path(out_dir, method, pheno, 'score_all', paste0(method, '-sum.txt'))

      if (pheno != "ad") {
        iid_file <- file.path(iid_base, pheno, paste0('rep', rep), paste0(pheno, '_train_phenotype'))
      } else {
        iid_file <- file.path(iid_base, 'AD_DNAnexus', paste0('rep', rep), 'AD_DNAnexus_train_phenotype')
      }

      if (!file.exists(score_file) | !file.exists(iid_file)) {
        results <- rbind(results, data.table(method, pheno, rep, score = NA))
        print("File DNE")
        next
      } 

      # Load files
      score_dt <- fread(score_file)
      iid_dt <- fread(iid_file)

      # Join based on IID
      merged <- merge(iid_dt[, .(IID)], score_dt, by = "IID")

      if (nrow(merged) == 0) {
        results <- rbind(results, data.table(method, pheno, rep, score = NA))
        next
      }

      prs <- data.frame(PRS = merged$PRS)

      # Calculate score
      if (binary) {
        score <- AUC_Score(prs, merged$phenotype)
      } else {
        score <- RSquared_Score(prs, merged$phenotype)
      }

      # Store result
      results <- rbind(results, data.table(method, pheno, rep, score))
    }
  }
}

# Output to file
fwrite(results, file = file.path(out_dir, "scores_by_rep.txt"), sep = "\t")
