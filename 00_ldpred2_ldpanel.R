library(bigsnpr)
library(dplyr)
library(readr)
library(data.table)

NCORES<-nb_cores()
# Load HapMap-like variants from the UKBB LD map
hapmap_map <- readRDS("/common/lir2lab/Olivia/LDPred2/ld_matrix/map.rds")

# We'll use chr and rsid to match
hapmap_variants <- hapmap_map %>% select(chr, rsid)

plink_path <- "/common/lir2lab/Olivia/Model-Evaluation/1kgReferencePanel/ref"
rds_out <- paste0(plink_path, ".rds")

if (!file.exists(rds_out)) {
  snp_readBed(paste0(plink_path, ".bed"))  # will create .rds and .bk files
}
obj.bigSNP <- snp_attach(rds_out)
G <- obj.bigSNP$genotypes
map <- obj.bigSNP$map
colnames(map) <- c("chr", "rsid", "cm", "pos", "a1", "a0")
map <- map %>% filter(cm > 0)

map$index <- 1:nrow(map)
map_hapmap <- inner_join(map, hapmap_variants, by = c("chr", "rsid"))
ind.keep <- map_hapmap$index

# Initialize output map
map_ldpred2 <- map_hapmap %>%
  select(chr, pos, a0, a1, rsid) %>%
  mutate(ld = NA_real_)

for (chr in 1:22) {
  cat("Processing chromosome", chr, "...\n")

  # Select variants for this chromosome
  ind.chr <- which(map_hapmap$chr == chr)
  ind.col <- map_hapmap$index[ind.chr]
  pos <- map_hapmap$cm[ind.chr]  # genetic distance
  #pos <- map_hapmap$pos[ind.chr]  # actual pos in bp

  # Compute correlation
  corr <- snp_cor(G, ind.col = ind.col, infos.pos = pos, size = 3 / 1000, ncores = NCORES)
  ld <- Matrix::colSums(corr^2)
  map_ldpred2$ld[ind.chr] <- ld
  # Save as .rds
  saveRDS(corr, file = sprintf("/common/lir2lab/Olivia/Model-Evaluation/ldpanel/bigsnpr_ldpanel_1kg_eur/ld_chr%d.rds", chr))
}

saveRDS(map_ldpred2, "/common/lir2lab/Olivia/Model-Evaluation/ldpanel/bigsnpr_ldpanel_1kg_eur/ld_map.rds")
