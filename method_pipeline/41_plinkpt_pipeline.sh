#!/bin/bash
#SBATCH --job-name=plinkpt
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/plinkpt/pipeline/41_plinkpt_pipeline_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/plinkpt/pipeline/41_plinkpt_pipeline_%A_%a.err  # Standard error log
#SBATCH --array=111-132
#SBATCH --cpus-per-task=20  # Number of cores per task
#SBATCH --time=2:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1
module load python

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")

pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) /22 )) 
chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))  # 1 to 22
pheno=${phenos[$pheno_index]}

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

# Inputs
out_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/plinkpt/${pheno}/"
mkdir -p "$(dirname "$out_dir")"
sumstats_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/${pheno}/${pheno}_chr${chr}_gwas"
genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"

/common/lir2lab/plink/plink2 --bfile $genotype \
--clump-p1 0.0001 \
--clump-p2 0.01 \
--clump-r2 0.5 \
--clump-kb 250 \
--clump $sumstats_file \
--clump-id-field SNP \
--clump-p-field P-value \
--clump-a1-field A1 \
--out ${out_dir}${pheno}_plinkpt_chr$chr