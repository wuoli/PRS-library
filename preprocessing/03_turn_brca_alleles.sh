#!/bin/bash

for chr in {1..22}; do
  input="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/breast_cancer_old/breast_cancer_chr${chr}_gwas"
  output="/common/lir2lab/Olivia/Model-Evaluation/consortium/result/sumstats/breast_cancer/breast_cancer_chr${chr}_gwas"
  awk -v OFS="\t" '
  NR == 1 {
      print
      next
  }
  {
      a1 = $4
      a2 = $5
      beta = $6
      eff_freq = $10

      if (eff_freq > 0.5) {
          $4 = a2
          $5 = a1
          $10 = 1-eff_freq
      }
      print
  }
  ' "$input" > "$output"
done
