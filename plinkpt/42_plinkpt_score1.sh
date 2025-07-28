#!/bin/bash
#SBATCH --job-name=plinkpt
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/plinkpt/score1/22_plinkpt_score_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/plinkpt/score1/22_plinkpt_score_%A_%a.err  # Standard error log
#SBATCH --array=111-132
#SBATCH --cpus-per-task=10  # Number of cores per task
#SBATCH --time=1:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")
#phenos=("breast_cancer")

# Calculate indices for phenotype and chromosome
pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) /22 )) 
chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))  # 1 to 22

# Get the phenotype
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/plinkpt/${pheno}/"
genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"
sumstats_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/${pheno}/${pheno}_chr${chr}_gwas"
clump_file="${out_dir}${pheno}_plinkpt_chr${chr}.clumps"

#TRAIN
pheno_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_train_phenotype"
score_dir="${out_dir}score_train/" 
mkdir -p $score_dir

/common/lir2lab/plink/plink2 --bfile $genotype \
--keep $pheno_file \
--extract $clump_file \
--score $sumstats_file 1 4 6 header \
--out ${score_dir}score-chr${chr}