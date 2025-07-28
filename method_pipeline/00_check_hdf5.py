import h5py

with h5py.File('/common/lir2lab/Okan/PRSCS/Codes/ldblk_ukbb_eur/ldblk_ukbb_chr1.hdf5', 'r') as f:
    first_block = f['blk_1']
    snplist = first_block['snplist'][:]  # Load the snplist array
    print("First 5 entries in snplist:", snplist[:5])  # Print first 5 SNPs
