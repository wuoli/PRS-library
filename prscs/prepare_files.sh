#!/bin/bash

# Set the base results directory
results_dir="/common/lir2lab/Olivia/Results/PRSO25/"

# Define arrays
phenos=("t2d" "hypertension" "hdl" "ldl" "bmi" "cholesterol")
reps=(1 2 3 4 5)
pvals=(0.05 0.005)

# Loop through phenotypes, p-values, and reps
for pheno in "${phenos[@]}"; do
  for pval in "${pvals[@]}"; do
    for rep in "${reps[@]}"; do
      
      # Define source directories
      src_dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pval}/${pheno}/rep${rep}"
      
      # Destination directories
      beta_dest="${results_dir}${pheno}/${pval}/rep${rep}/prscs/betas/"
      prs_dest="${results_dir}${pheno}/${pval}/rep${rep}/prscs/score_test/"

      # Create destination directories if they do not exist
      mkdir -p "$beta_dest"
      mkdir -p "$prs_dest"

      # Copy beta files (one per chromosome)
      for chr in {1..22}; do
        beta_file="${src_dir}/betas/_pst_eff_a1_b0.5_phiauto_chr${chr}.txt"
        if [[ -f "$beta_file" ]]; then
          cp "$beta_file" "${beta_dest}/"
        else
          echo "Missing beta file: $beta_file"
        fi

        # Copy PRS files
        prs_file="${src_dir}/score_test/prscs-chr${chr}.sscore"
        if [[ -f "$prs_file" ]]; then
          cp "$prs_file" "${prs_dest}/"
        else
          echo "Missing PRS file: $prs_file"
        fi
      done

    done
  done
done
