
PRScs Pipeline
1. Download PRScs from https://github.com/getian107/PRScs 
2. Download ldpanel reference panels (1kg or ukbb) from https://github.com/getian107/PRScs
3. Format your GWAS file in the following way:
   SNP    A1   A2   BETA      SE 
4. Run PRScs pipeline `11_prscs_pipeline` (per chromosome)
   - Required inputs: $out_dir $sumstats_file $genotype $n_gwas $chr $ld_panel $prscs_dir
   - Dependency: `MethodEval.R` (you can also just extract the PRScs function from there)
5. Calculate scores `12_prscs_score1` (per chromosome)
6. Add scores up for each individual `12_prscs_score2`
7. Evaluate `13_prscs_evaluate` (or use `51_evaluate_cv` for everything)
 
