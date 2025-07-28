# Get the best scores from the validation data and put them in one file.
# Then, get the scores from the corresponding models in the testing data.

library(data.table)
library(ROCR)

out_dir <- '/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/'
# NOTE: REMOVE RA for 0.05 and 0.005 experiments
phenos <- c("t2d", "AD_DNAnexus", "breast_cancer", "hypertension", "RA", "hdl", "ldl", "bmi", "cholesterol")
reps <- 1:5
binaries <- c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE) 

# Function to calculate AUC score for binary phenotype
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
test_scores <- data.frame(matrix(ncol = length(phenos), nrow = length(reps)))
colnames(test_scores) <- phenos
rownames(test_scores) <- reps  # Row names should just be rep numbers
#test_score_file <- paste0(out_dir, 'testing_scores.txt')
test_score_file <- paste0(out_dir, 'validation_scores.txt')

for (pheno_idx in seq_along(phenos)) { 
    binary <- as.logical(binaries[pheno_idx])  
    pheno <- phenos[pheno_idx]
    
    for (rep in reps) {  
        file_dir <- paste0(out_dir, pheno, '/rep', rep, '/')
        #score_sum <- fread(paste0(file_dir, 'score_test/prscs-sum.txt'))
        score_sum <- fread(paste0(file_dir, 'score_val/prscs-sum.txt'))
        #score_sum <- fread(paste0(file_dir, 'score_train/prscs-sum.txt'))
        prs <- data.frame(PRS=score_sum$PRS)
        
        if (as.logical(binary)) { 
            score <- AUC_Score(prs, score_sum$phenotype)
        } else {
            score <- RSquared_Score(prs, score_sum$phenotype)
        }

        test_scores[as.character(rep), pheno] <- score
    }
} 
write.table(test_scores, test_score_file, quote = FALSE, row.names = TRUE, col.names = TRUE)
