#!/bin/bash

categories=("train" "val" "test")
phenos=("t2d" "AD_DNAnexus" "breast_cancer" "hypertension" "hdl" "ldl" "bmi" "cholesterol")

for pheno in "${phenos[@]}"; do
  for category in "${categories[@]}"; do

    # Paths
    iid_file="/common/lir2lab/Wanling/FDR_AB_PRS/IID_split/${pheno}_${category}_id"
    pheno_file="/common/lir2lab/Wanling/DATA/QC1/Phenotype/${pheno}_phenotype"
    output_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_${category}_phenotype"

    # Extract matching phenotypes and format
    awk 'NR==FNR{a[$1]; next} ($1 in a){print $1, $1, $2}' "${iid_file}" "${pheno_file}" > "${output_file}"

    echo "Saved: ${output_file}"
  done
done
