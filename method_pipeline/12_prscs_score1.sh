#!/bin/bash
#SBATCH --job-name=prscs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/prscs/score1/12_prscs_score1_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/prscs/score1/12_prscs_score1_%A_%a.err  # Standard error log
#SBATCH --array=133-154
#SBATCH --cpus-per-task=20  # Number of cores per task
#SBATCH --time=10:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")

# Calculate indices for phenotype, replicate, and chromosome
pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) /22 )) 
chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))

# Get the phenotype, rep
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/prscs/${pheno}/"
genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"
betas_file="${out_dir}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt"

#TRAIN
#pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_train_phenotype"
#score_dir="${out_dir}score_train/" 

#ALL
pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_phenotype"
score_dir="${out_dir}score_all/" 

Rscript /common/lir2lab/Olivia/Model-Evaluation/code/prscs/prscs1_2P1.R $pheno $chr $pheno_file $betas_file $score_dir $genotype