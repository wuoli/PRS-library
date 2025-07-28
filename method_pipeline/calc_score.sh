#!/bin/bash
#SBATCH --job-name=prscs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/%A_%a.err  # Standard error log
#SBATCH --array=1
#SBATCH --cpus-per-task=20  # Number of cores per task
#SBATCH --time=10:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1
module load python

#phenos=("t2d" "AD_DNAnexus" "breast_cancer" "hypertension" "RA" "hdl" "ldl" "bmi" "cholesterol")
#binarys=("T" "T" "T" "T" "T" "F" "F" "F" "F")
#reps=(1 2 3 4 5)

# Calculate indices for phenotype, replicate, and chromosome
# pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) / (22 * 5) ))  # 0 to 7
# rep_index=$(( ( (SLURM_ARRAY_TASK_ID - 1) / 22 ) % 5 ))  # 0 to 4
 chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))  # 1 to 22

# Get the phenotype, rep
#pheno=${phenos[$pheno_index]}
pheno="t2d"

echo "Processing Phenotype ${pheno} Chromosome ${chr}"

#Output Directory
score_dir="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/prscs/"

sumstat_file="/common/lir2lab/Olivia/Model-Evaluation/sumstats_consortiums/finngen_R12_T2D"
phenotype_file="/common/lir2lab/Wanling/FDR_AB_PRS/IID_split/t2d_test_id"
genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"

Rscript /common/lir2lab/Olivia/Model-Evaluation/consortium/code/calc_score.R $pheno $chr $phenotype_file $sumstat_file $score_dir $genotype