import h5py

hdf5_path_template = '/common/lir2lab/Okan/PRSCS/Codes/ldblk_ukbb_eur/ldblk_ukbb_chr{}.hdf5'

for chr_num in range(1, 23):
    file_path = hdf5_path_template.format(chr_num)
    snps = []
    with h5py.File(file_path, 'r') as f:
        for blk in f.keys():
            block = f[blk]
            snplist = block['snplist'][:]
            snps.extend([snp.decode('utf-8') for snp in snplist])
    snp_set = set(snps)
    with open(f'/common/lir2lab/Olivia/Model-Evaluation/consortium/result/snp_list/snp_list_chr{chr_num}.txt', 'w') as out_file:
        for snp in snp_set:
            out_file.write(snp + '\n')
    print(f'Chromosome {chr_num}: {len(snp_set)} SNPs extracted and saved to snp_list_chr{chr_num}.txt')
