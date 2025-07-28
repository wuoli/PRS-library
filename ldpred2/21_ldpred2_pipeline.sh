#!/bin/bash
#SBATCH --job-name=ldpred2
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/ldpred2/pipeline/21_ldpred2_pipeline_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/ldpred2/pipeline/21_ldpred2_pipeline_%A_%a.err  # Standard error log
#SBATCH --array=8
#SBATCH --cpus-per-task=35  # Number of cores per task
#SBATCH --time=12:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")
neff_dirs=("/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/hdl/" "/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/ldl/" "/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/cholesterol/" "/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/bmi/" "898130" "247173" "63926" "49141")
neff_cols=(6 6 6 8 -1 -1 -1 -1)
# Calculate index for phenotype
pheno_index=${SLURM_ARRAY_TASK_ID}-1
pheno=${phenos[$pheno_index]}
neff_dir=${neff_dirs[$pheno_index]}
neff_col=${neff_cols[$pheno_index]}

echo "Processing Phenotype ${pheno}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/ldpred2/${pheno}/"
sumstats_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats_prscs/${pheno}/"
betas_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/ldpred2/${pheno}/"

Rscript /common/lir2lab/Olivia/Model-Evaluation/consortium/code/21_ldpred2_pipeline.R $pheno $betas_dir $sumstats_dir $neff_dir $neff_col