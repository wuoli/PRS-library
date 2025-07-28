library(data.table)
library(ROCR)

out_dir <- '/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/'

phenos <- c("t2d", "AD_DNAnexus", "breast_cancer", "hypertension", "RA", "hdl", "ldl", "bmi", "cholesterol")
reps <- 1:5
binaries <- c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)

# Function to calculate AUC
AUC_Score <- function(true_labels, predicted_scores) {
  pred <- prediction(predicted_scores, true_labels)
  auc <- performance(pred, measure = "auc")@y.values[[1]]
  return(auc)
}

# Function to calculate R2
RSquared_Score <- function(true, predicted) {
  ss_res <- sum((true - predicted)^2)
  ss_tot <- sum((true - mean(true))^2)
  r2 <- 1 - ss_res/ss_tot
  return(r2)
}

# Initialize table
test_scores <- data.frame(matrix(ncol = length(phenos), nrow = length(reps)))
colnames(test_scores) <- phenos
rownames(test_scores) <- reps

test_score_file <- paste0(out_dir, 'testing_scores.txt')

for (pheno_idx in seq_along(phenos)) { 
  binary <- as.logical(binaries[pheno_idx])
  pheno <- phenos[pheno_idx]
  
  for (rep in reps) {
    file_dir <- paste0(out_dir, pheno, '/rep', rep, '/')
    
    # Read scores
    train_scores <- fread(paste0(file_dir, 'score_train/prscs-sum.txt'))
    val_scores <- fread(paste0(file_dir, 'score_test/prscs-sum.txt'))  # or score_test if you change later
    
    # Train the model on TRAINING
    model <- if (binary) {
      glm(phenotype ~ PRS, data = train_scores, family = "binomial")
    } else {
      lm(phenotype ~ PRS, data = train_scores)
    }
    
    # Save model
    model_dir <- paste0(file_dir, 'score_train/model/')
    dir.create(model_dir, recursive = TRUE, showWarnings = FALSE)
    saveRDS(model, file = paste0(model_dir, 'model.rds'))
    
    # Predict on VALIDATION/TEST set
    preds <- predict(model, newdata = val_scores, type = if (binary) "response" else "response")
    
    # Calculate performance
    if (binary) {
      score <- AUC_Score(val_scores$phenotype, preds)
    } else {
      score <- RSquared_Score(val_scores$phenotype, preds)
    }
    
    # Save score
    test_scores[as.character(rep), pheno] <- score
  }
}

# Write scores
write.table(test_scores, test_score_file, quote = FALSE, row.names = TRUE, col.names = TRUE)
