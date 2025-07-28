#!/bin/bash
#SBATCH --job-name=prscs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/prscs/score2/12_prscs_score2_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/prscs/score2/12_prscs_score2_%A_%a.err  # Standard error log
#SBATCH --array=7
#SBATCH --cpus-per-task=10  # Number of cores per task
#SBATCH --time=2:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")

pheno_index=$SLURM_ARRAY_TASK_ID-1
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/prscs/${pheno}/"
#TRAIN
# pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_train_phenotype"
# score_dir="${out_dir}score_train/" 

#ALL
pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_phenotype"
score_dir="${out_dir}score_all/" 

Rscript /common/lir2lab/Olivia/Model-Evaluation/code/prscs/prscs1_2P2.R $pheno $pheno_file $score_dir