#!/bin/bash

for pheno in "t2d" "AD_DNAnexus" "breast_cancer" "hypertension" "RA" "hdl" "ldl" "bmi" "cholesterol"; do
    for rep in {1..5}; do
        for chr in {1..22}; do
            for score_type in score_val score_test; do
            dir="/common/lir2lab/Olivia/Model-Evaluation/PRScs_hapmap/${pheno}/rep${rep}/${score_type}"
            old_file="${dir}/ldpred2-chr${chr}.log"
            new_file="${dir}/prscs-chr${chr}.log"

            if [[ -f "$old_file" ]]; then
                mv "$old_file" "$new_file"
                echo "Renamed $old_file → $new_file"
            else
                echo "Missing: $old_file"
            fi
            done
        done
    done
done
