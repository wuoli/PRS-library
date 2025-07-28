#!/bin/sh

#phenos=("hdl" "ldl" "cholesterol" "bmi" "t2d" "breast_cancer" "ad" "hypertension")
phenotype="breast_cancer"

for chr in {1..22}; do
  input_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/${phenotype}/${phenotype}_chr${chr}_gwas"
  output_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats_megaprs/${phenotype}/${phenotype}_chr${chr}_gwas"

  # Create output directory if it doesn't exist
  mkdir -p "$(dirname "$output_file")"

  # Extract header and replace with desired header
  echo -e "Predictor\tA1\tA2\tn\tDirection\tP\tA1Freq" > "$output_file"
  # For BMI and AD:
  #echo -e "Predictor\tA1\tA2\tn\tDirection\tP" > "$output_file"

  # Process the file skipping the header line (NR>1), remove duplicates, and print desired columns
   awk 'NR>1 {
    if (!seen[$1]++) {
       print $1, $4, $5, 247173, $6, $8, $10
    }
  }' OFS='\t' "$input_file" >> "$output_file"

  # For HDL, LDL, Cholesterol:
  # print $1, $5, $4, $6, $9, $12, $8
  # For BMI; remove NA for Freq1.Hapmap ($4)
  # print $1, $2, $3, $8, $5, $7
  # For T2D
  # print $1, $4, $5, 898130, $7, $9, $6
  # For Breast Cancer
  # print $1, $4, $5, 247173, $6, $8, $10
  # For AD (CHANGE SEEN= $3)
  # print $3, $4, $5, 63926, $6, $8 
  # For Hypertension (CHANGE SEEN=$14)
  # print $14, $5, $4, $7, $10, $12, $6
done