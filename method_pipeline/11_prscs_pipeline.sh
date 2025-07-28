#!/bin/bash
#SBATCH --job-name=prscs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/prscs/pipeline/11_prscs_pipeline_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/prscs/pipeline/11_prscs_pipeline_%A_%a.err  # Standard error log
#SBATCH --array=111-132
#SBATCH --cpus-per-task=20  # Number of cores per task
#SBATCH --time=1:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1
module load python

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")

# Calculate indices for phenotype, replicate, and chromosome
pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) /22 )) 
chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))  # 1 to 22

# Get the phenotype, rep
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/prscs/${pheno}/"
sumstats_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats_prscs/${pheno}/${pheno}_chr${chr}_gwas"
genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"
n_gwas=247173

Rscript /common/lir2lab/Olivia/Model-Evaluation/code/prscs/prscs1_1.R $out_dir $sumstats_file $genotype $n_gwas $chr