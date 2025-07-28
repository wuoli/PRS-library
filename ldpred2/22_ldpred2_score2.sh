#!/bin/bash
#SBATCH --job-name=ldpred2
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/ldpred2/score2/22_ldpred2_score_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/ldpred2/score2/22_ldpred2_score_%A_%a.err  # Standard error log
#SBATCH --array=7
#SBATCH --cpus-per-task=10  # Number of cores per task
#SBATCH --time=2:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

#Note: this bash file contains both part 1(calculate PRS for each chr) and part 2(summing scores)
module load R/4.2.1

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")
#phenos=("breast_cancer")

# Get the phenotype
pheno_index=$SLURM_ARRAY_TASK_ID-1
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/ldpred2/${pheno}/"

#TRAIN
# pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_train_phenotype"
# score_dir="${out_dir}score_train/" 

#ALL
pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_phenotype"
score_dir="${out_dir}score_all/" 

#FOR PART2: When running part 2, only run phenotype once (1, 23, 45, etc..)
Rscript /common/lir2lab/Olivia/Model-Evaluation/consortium/code/22_ldpred2_score2.R $pheno $pheno_file $score_dir
