#!/bin/bash
#SBATCH --job-name=megaprs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/megaprs/score1/32_megaprs_score1_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/megaprs/score1/32_megaprs_score1_%A_%a.err  # Standard error log
#SBATCH --array=133-154
#SBATCH --cpus-per-task=15  # Number of cores per task
#SBATCH --time=8:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

#Note: this bash file contains both part 1(calculate PRS for each chr) and part 2(summing scores)
module load R/4.2.1

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")

# Calculate indices for phenotype, replicate, and chromosome
pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) /22 )) 
chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))  # 1 to 22

# Get the phenotype
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/megaprs/${pheno}/"
genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"
betas_file="${out_dir}mega${chr}.effects"

#TRAIN
# pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_train_phenotype"
# score_dir="${out_dir}score_train/" 

#ALL
pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_phenotype"
score_dir="${out_dir}score_all/" 

Rscript /common/lir2lab/Olivia/Model-Evaluation/consortium/code/32_megaprs_score1.R $pheno $chr $pheno_file $betas_file $score_dir $genotype