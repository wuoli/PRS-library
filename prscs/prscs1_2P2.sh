#!/bin/bash
#SBATCH --job-name=prscs1_2P2
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/logs/prscs1_pval/step2P2/%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/logs/prscs1_pval/step2P2/%A_%a.err  # Standard error log
#SBATCH --array=1-45
#SBATCH --cpus-per-task=15  # Number of cores per task
#SBATCH --time=1:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1

phenos=("t2d" "AD_DNAnexus" "breast_cancer" "hypertension" "RA" "hdl" "ldl" "bmi" "cholesterol")
reps=(1 2 3 4 5)
binarys=("T" "T" "T" "T" "T" "F" "F" "F" "F")

# Calculate indices for phenotype and replicate
pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) / 5 ))  # Phenotype index (0 to 8)
rep_index=$(( (SLURM_ARRAY_TASK_ID - 1) % 5 ))   # Replicate index (0 to 4)

# Get the phenotype, replicate, and binary indicator
pheno=${phenos[$pheno_index]}
rep=${reps[$rep_index]}
binary=${binarys[$pheno_index]}
pval=0.005
out_dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pheno}/rep${rep}/"
#out_dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pval}/${pheno}/rep${rep}/"

#VAL
# pheno_file="/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/${pheno}/rep${rep}/${pheno}_val_phenotype"
# score_dir="${out_dir}score_val/" 

#TEST
#pheno_file="/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/${pheno}/rep${rep}/${pheno}_test_phenotype"
#score_dir="${out_dir}score_test/" 

#TRAIN
pheno_file="/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/${pheno}/rep${rep}/${pheno}_train_phenotype"
score_dir="${out_dir}score_train/" 

Rscript /common/lir2lab/Olivia/Model-Evaluation/code/prscs1_2P2.R $pheno $rep $binary $pheno_file $score_dir
