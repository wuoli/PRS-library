library(data.table)
library(ROCR)

out_dir <- '/common/lir2lab/Olivia/Model-Evaluation/consortium/result/'
methods <- c('prscs', 'ldpred2', 'megaprs', 'plinkpt')
#methods <- c('ldpred2')
phenos <- c("t2d", "breast_cancer", "ad", "hypertension", "hdl", "ldl", "bmi", "cholesterol")
binaries <- c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE) 
# phenos <- c("t2d", "hdl", "ldl", "bmi", "cholesterol")
# binaries <- c(TRUE, FALSE, FALSE, FALSE, FALSE) 

# Function to calculate AUC
AUC_Score <- function(prs, pheno) {
  mod <- glm(pheno ~ PRS, data = prs, family = "binomial")
  pred <- prediction(predict(mod, prs, type = "response"), pheno)
  auc <- performance(pred, measure = "auc")@y.values[[1]]
  return(auc)
}

# Function to calculate R-squared score for continuous phenotype
RSquared_Score <- function(prs, pheno) {
  mod <- lm(pheno ~ PRS, data = prs)
  r2 <- summary(mod)$r.squared
  return(r2)
}

# Initialize test_scores with correct structure
test_scores <- data.frame(matrix(ncol = length(phenos), nrow = length(methods)))
colnames(test_scores) <- phenos
rownames(test_scores) <- methods
test_score_file <- paste0(out_dir, 'scores.txt')

for(method_idx in seq_along(methods)){
    method <- methods[method_idx]
    for (pheno_idx in seq_along(phenos)) {  
        binary <- as.logical(binaries[pheno_idx])  
        pheno <- phenos[pheno_idx]

        score_file <- paste0(out_dir, method, '/', pheno, '/score_train/', method, '-sum.txt')
        if(!file.exists(score_file)){test_scores[method, pheno] <- NA; next}
        score_sum <- fread(score_file)
        prs <- data.frame(PRS=score_sum$PRS)
        
        if (as.logical(binary)) { 
            score <- AUC_Score(prs, score_sum$phenotype)
        } else {
            score <- RSquared_Score(prs, score_sum$phenotype)
        }

        test_scores[method, pheno] <- score
    }
}

write.table(test_scores, test_score_file, quote = FALSE, row.names = TRUE, col.names = TRUE)
