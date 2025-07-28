#!/bin/bash
#SBATCH --job-name=prscs1_2
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/logs/prscs1/step2/%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/logs/prscs1/step2/%A_%a.err  # Standard error log
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
#pval=0.05

echo "Processing Phenotype ${pheno} Rep ${rep} Chromosome ${chr}"

#Output Directory
out_dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pheno}/rep${rep}/"
#out_dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pval}/${pheno}/rep${rep}/"
betas_dir="${out_dir}betas/"
betas_file="${betas_dir}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt"

genotype="/common/lir2lab/Wanling/DATA/UKBB/Genotype/chr${chr}"

#VAL
#pheno_file="/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/${pheno}/rep${rep}/${pheno}_val_phenotype"
#score_dir="${out_dir}score_val/" 

#TEST
#pheno_file="/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/${pheno}/rep${rep}/${pheno}_test_phenotype"
#score_dir="${out_dir}score_test/" 

#TRAIN
pheno_file="/common/lir2lab/Wanling/DATA/GWAS_HapMap3/HapMap3_QC2/${pheno}/rep${rep}/${pheno}_train_phenotype"
score_dir="${out_dir}score_train/" 


Rscript /common/lir2lab/Olivia/Model-Evaluation/code/prscs1_2P1.R $pheno $rep $chr $pheno_file $betas_file $score_dir $genotype