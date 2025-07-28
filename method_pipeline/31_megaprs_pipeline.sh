#!/bin/bash
#SBATCH --job-name=megaprs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/megaprs/pipeline/31_megaprs_pipeline_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/megaprs/pipeline/31_megaprs_pipeline_%A_%a.err  # Standard error log
#SBATCH --array=6
#SBATCH --cpus-per-task=35  # Number of cores per task
#SBATCH --time=2:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load R/4.2.1
module load python

phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")

# Get Phenotype
pheno_index=$((SLURM_ARRAY_TASK_ID - 1))
pheno=${phenos[$pheno_index]}

# calculate 
for j in {1..22}; do
    echo "Processing Phenotype ${pheno} Chromosome $j"

    #Part 2: calculate effect size
    sumstats="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats_megaprs/${pheno}/${pheno}_chr${j}_gwas"
    cor="/common/lir2lab/Olivia/Model-Evaluation/megaprs/cors/cors$j"
    annotation="/common/lir2lab/Olivia/Model-Evaluation/megaprs/BaselineLD/BaselineLD$j"
    outfile="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/megaprs/${pheno}/mega$j"
    mkdir -p "$(dirname "$outfile")"

    /common/lir2lab/Olivia/Model-Evaluation/megaprs/ldak6.1.out --mega-prs $outfile --summary $sumstats --cors $cor --power -0.25 --check-sums NO --chr $j --max-threads 33
    
done
