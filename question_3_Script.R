setwd("C:/Users/sunan/Downloads/abundance")
#install.packages(c("ggplot2", "dplyr", "tidyr", "readr", "pheatmap"))
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(pheatmap)
genus_counts <- read_tsv("genus_counts.tsv")
species_counts <- read_tsv("species_counts.tsv")

head(genus_counts)
head(species_counts)

dim(genus_counts)
dim(species_counts)


# Convert long count tables into sample-by-taxon matrices
genus_wide <- genus_counts %>%
  pivot_wider(
    names_from = Genus,
    values_from = Count,
    values_fill = 0
  ) %>%
  arrange(Sample)

species_wide <- species_counts %>%
  pivot_wider(
    names_from = Species,
    values_from = Count,
    values_fill = 0
  ) %>%
  arrange(Sample)

# Convert to matrices
genus_mat <- as.data.frame(genus_wide)
rownames(genus_mat) <- genus_mat$Sample
genus_mat$Sample <- NULL
genus_mat <- as.matrix(genus_mat)

species_mat <- as.data.frame(species_wide)
rownames(species_mat) <- species_mat$Sample
species_mat$Sample <- NULL
species_mat <- as.matrix(species_mat)

# Calculate TSS
genus_totals <- rowSums(genus_mat)
species_totals <- rowSums(species_mat)

genus_tss <- sweep(
  genus_mat, 1, ifelse(genus_totals == 0, 1, genus_totals), "/"
)

species_tss <- sweep(
  species_mat, 1, ifelse(species_totals == 0, 1, species_totals), "/"
)

# Save normalized matrices
write.csv(genus_tss, "genus_TSS.csv")
write.csv(species_tss, "species_TSS.csv")

# Check row sums
round(rowSums(genus_tss), 4)
round(rowSums(species_tss), 4)
























species_mean <- colMeans(species_tss)

species_mean_df <- data.frame(
  Species = names(species_mean),
  Mean_Abundance = as.numeric(species_mean)
) %>%
  arrange(desc(Mean_Abundance))

top20_species <- species_mean_df %>%
  slice_head(n = 20)

print(top20_species)

write.csv(
  top20_species,
  "top20_species_mean_abundance.csv",
  row.names = FALSE
)

















top20_species$Species <- factor(
  top20_species$Species,
  levels = rev(top20_species$Species)
)

p_top20 <- ggplot(
  top20_species,
  aes(x = Species, y = Mean_Abundance)
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 20 species by mean relative abundance",
    x = "Species",
    y = "Mean relative abundance (TSS)"
  ) +
  theme_minimal(base_size = 12)

print(p_top20)

ggsave(
  "top20_species_barplot.png",
  plot = p_top20,
  width = 10,
  height = 8,
  dpi = 300
)





genus_mean <- colMeans(genus_tss)

top15_genera <- names(
  sort(genus_mean, decreasing = TRUE)
)[1:min(15, length(genus_mean))]

genus_heatmap <- t(genus_tss[, top15_genera, drop = FALSE])

pheatmap(
  genus_heatmap,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  main = "Top 15 genera across 12 samples",
  color = colorRampPalette(
    c("white", "gold", "red")
  )(100),
  filename = "top15_genera_heatmap.png",
  width = 10,
  height = 8
)






top_species_names <- as.character(top20_species$Species)

species_heatmap <- t(
  species_tss[, top_species_names, drop = FALSE]
)

pheatmap(
  species_heatmap,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  main = "Top 20 species across 12 samples",
  color = colorRampPalette(
    c("white", "skyblue", "darkblue")
  )(100),
  filename = "top20_species_heatmap.png",
  width = 12,
  height = 9
)








dominant_genus <- apply(
  genus_tss, 1, function(x) names(which.max(x))
)

dominant_species <- apply(
  species_tss, 1, function(x) names(which.max(x))
)

dominant_table <- data.frame(
  Sample = rownames(genus_tss),
  Dominant_Genus = dominant_genus,
  Genus_Relative_Abundance = apply(
    genus_tss, 1, max
  ),
  Dominant_Species = dominant_species,
  Species_Relative_Abundance = apply(
    species_tss, 1, max
  )
)

print(dominant_table)

write.csv(
  dominant_table,
  "dominant_taxa_per_sample.csv",
  row.names = FALSE
)

