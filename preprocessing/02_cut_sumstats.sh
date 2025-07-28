#!/bin/bash
#SBATCH --job-name=prscs
#SBATCH --output=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/02_cut_sumstats_%A_%a.out # Standard output log
#SBATCH --error=/common/lir2lab/Olivia/Model-Evaluation/consortium/result/log/02_cut_sumstats_%A_%a.err  # Standard error log
#SBATCH --array=1
#SBATCH --cpus-per-task=20  # Number of cores per task
#SBATCH --time=10:00:00      # Time limit
#SBATCH --mem=64G           # Memory per job
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks (processes)
#SBATCH -p preemptable,defq

module load python
#python /common/lir2lab/Olivia/Model-Evaluation/consortium/code/02_cut_sumstats.py
#python /common/lir2lab/Olivia/Model-Evaluation/consortium/code/02_cut_t2d_sumstats.py
python /common/lir2lab/Olivia/Model-Evaluation/consortium/code/02_cut_braca_sumstats.py