#!/bin/bash
#SBATCH --job-name=prscs1_1
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/logs/prscs1_pval/step1/%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/logs/prscs1_pval/step1/%A_%a.err  # Standard error log
#SBATCH --array=1-990
#SBATCH --cpus-per-task=20  # Number of cores per task
#SBATCH --time=10:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1
module load python

phenos=("t2d" "AD_DNAnexus" "breast_cancer" "hypertension" "RA" "hdl" "ldl" "bmi" "cholesterol")
#binarys=("T" "T" "T" "T" "T" "F" "F" "F" "F")
reps=(1 2 3 4 5)

# Calculate indices for phenotype, replicate, and chromosome
pheno_index=$(( (SLURM_ARRAY_TASK_ID - 1) / (22 * 5) ))  # 0 to 7
rep_index=$(( ( (SLURM_ARRAY_TASK_ID - 1) / 22 ) % 5 ))  # 0 to 4
chr=$(( (SLURM_ARRAY_TASK_ID - 1) % 22 + 1 ))  # 1 to 22

# Get the phenotype, rep
pheno=${phenos[$pheno_index]}
rep=${reps[$rep_index]}
pval=0.005

echo "Processing Phenotype ${pheno} Rep ${rep} Chromosome ${chr}"
echo "Pvalue: ${pval}"

#Output Directory
out_dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pval}/${pheno}/rep${rep}/"
betas_dir="${out_dir}betas/"

#all version:
#new_sumstats_file="/common/lir2lab/Olivia/Model-Evaluation/sumstats_prscs/all/${pheno}/rep${rep}/${pheno}_rep${rep}_chr${chr}_gwas.txt"
#pval version:
new_sumstats_file="/common/lir2lab/Olivia/Model-Evaluation/sumstats_prscs/ss_${pval}/${pheno}/rep${rep}/${pheno}_rep${rep}_chr${chr}_gwas.txt"

genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"
n_gwas=301903

Rscript /common/lir2lab/Olivia/Model-Evaluation/code/prscs1_1.R $betas_dir $new_sumstats_file $genotype $n_gwas $chr