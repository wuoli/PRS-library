#!/bin/bash

phenos=("t2d" "AD_DNAnexus" "breast_cancer" "hypertension" "hdl" "ldl" "bmi" "cholesterol")

for pheno in "${phenos[@]}"; do

    # Paths
    iid_file="/common/lir2lab/Wanling/DATA/QC1/Phenotype/${pheno}_phenotype"
    output_file="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/iid/${pheno}_phenotype"

    # Extract matching phenotypes and format, skipping the header (NR > 1)
    awk 'NR > 1 {print $1, $1, $2}' "${iid_file}" > "${output_file}"

    echo "Saved: ${output_file}"

done