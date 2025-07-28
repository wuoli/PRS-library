LDPred2 Pipeline
1. Download bigsnpr using install.packages('bigsnpr')
2. Download ldpanel reference panel or diy it:
- UKBB: https://figshare.com/articles/dataset/LD_reference_for_HapMap3_/21305061
- DIY(do-it-yourself): `00_ldpred2_ldpanel.R` (need reference genome in plink format)
3. Format your GWAS file in the following way:
   SNP    A1   A2   BETA      SE 
4. neff (effective sample size): In my code, I set neff as either a column from files in a directory or a number that is the same for all snps. You *should modify* a code that fits your format.
5. Run ldpred2 pipeline `21_ldpred2_pipeline` (per chromosome)
   - Required inputs: $out_dir $sumstats_file $genotype $n_gwas $chr $ld_panel $prscs_dir
   - Dependency: `MethodEval.R` (you can also just extract the PRScs function from there)
5. Calculate scores `22_ldpred2_score1` (per chromosome)
6. Add scores up for each individual `12_ldpred2_score2` to obtain final prs score.