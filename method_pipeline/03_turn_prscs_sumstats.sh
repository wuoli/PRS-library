#!/bin/sh
phenotype='hypertension'

for chr in {1..22}; do
  input_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/${phenotype}/${phenotype}_chr${chr}_gwas"
  output_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats_prscs/${phenotype}/${phenotype}_chr${chr}_gwas"

  # Create output directory if it doesn't exist
  mkdir -p "$(dirname "$output_file")"

  # Extract header and replace with desired header
  echo -e "SNP\tA1\tA2\tBETA\tSE" > "$output_file"

  awk 'NR>1 {print $14, $5, $4, $10, $11}' OFS='\t' "$input_file" >> "$output_file"

  # Process the file skipping the header line (NR>1), print desired columns
  # For HDL, LDL, Cholesterol:
  #awk 'NR>1 {print $1, $5, $4, $9, $10}' OFS='\t' "$input_file" >> "$output_file"
  # For BMI
  #awk 'NR>1 {print $1, $2, $3, $5, $6}' OFS='\t' "$input_file" >> "$output_file"
  # For T2D
  # awk 'NR>1 {print $1, $4, $5, $7, $8}' OFS='\t' "$input_file" >> "$output_file"
  # For Breast Cancer
  # awk 'NR>1 {print $1, $4, $5, $6, $7}' OFS='\t' "$input_file" >> "$output_file"
  # For AD
  # awk 'NR>1 {print $3, $4, $5, $6, $7}' OFS='\t' "$input_file" >> "$output_file"
  # For Hypertension
  # awk 'NR>1 {print $14, $5, $4, $10, $11}' OFS='\t' "$input_file" >> "$output_file"
done
