library(ggplot2)
library(dplyr)
library(tidyr)

# Select the 10 most abundant genera across all samples
top10_genera <- names(
  sort(colMeans(genus_tss), decreasing = TRUE)
)[1:min(10, ncol(genus_tss))]

# Convert the matrix to long format
genus_long <- as.data.frame(genus_tss) %>%
  tibble::rownames_to_column("Sample") %>%
  pivot_longer(
    cols = -Sample,
    names_to = "Genus",
    values_to = "Relative_Abundance"
  ) %>%
  mutate(
    Genus = ifelse(Genus %in% top10_genera,
                   Genus, "Other")
  ) %>%
  group_by(Sample, Genus) %>%
  summarise(
    Relative_Abundance = sum(Relative_Abundance),
    .groups = "drop"
  )

# Plot
p_genus <- ggplot(
  genus_long,
  aes(x = Sample, y = Relative_Abundance, fill = Genus)
) +
  geom_col(width = 0.8) +
  labs(
    title = "Genus-level microbial composition",
    x = "Samples",
    y = "Relative abundance (TSS)",
    fill = "Genus"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(
      angle = 45, hjust = 1
    )
  )

print(p_genus)

ggsave(
  "genus_composition_12_samples.png",
  p_genus, width = 12, height = 7, dpi = 300
)







# Select the 10 most abundant species
top10_species <- names(
  sort(colMeans(species_tss), decreasing = TRUE)
)[1:min(10, ncol(species_tss))]

species_long <- as.data.frame(species_tss) %>%
  tibble::rownames_to_column("Sample") %>%
  pivot_longer(
    cols = -Sample,
    names_to = "Species",
    values_to = "Relative_Abundance"
  ) %>%
  mutate(
    Species = ifelse(
      Species %in% top10_species,
      Species, "Other"
    )
  ) %>%
  group_by(Sample, Species) %>%
  summarise(
    Relative_Abundance = sum(Relative_Abundance),
    .groups = "drop"
  )

p_species <- ggplot(
  species_long,
  aes(x = Sample, y = Relative_Abundance, fill = Species)
) +
  geom_col(width = 0.8) +
  labs(
    title = "Species-level microbial composition",
    x = "Samples",
    y = "Relative abundance (TSS)",
    fill = "Species"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(
      angle = 45, hjust = 1
    )
  )

print(p_species)

ggsave(
  "species_composition_12_samples.png",
  p_species, width = 14, height = 8, dpi = 300
)





# Taxon prevalence and maximum abundance
taxon_summary <- function(mat, rank_name) {
  
  data.frame(
    Taxon = colnames(mat),
    Prevalence = colSums(mat > 0),
    Mean_Abundance = colMeans(mat),
    Max_Abundance = apply(mat, 2, max),
    Max_Abundance_Sample = apply(
      mat, 2, function(x) rownames(mat)[which.max(x)]
    )
  ) %>%
    mutate(
      Rank = rank_name,
      Detection = case_when(
        Prevalence == nrow(mat) ~ "Detected in all samples",
        Prevalence == 1 ~ "Detected in one sample",
        TRUE ~ "Detected in multiple samples"
      )
    ) %>%
    arrange(desc(Mean_Abundance))
}

genus_summary <- taxon_summary(genus_tss, "Genus")
species_summary <- taxon_summary(species_tss, "Species")

# Save complete summary tables
write.csv(
  genus_summary,
  "genus_prevalence_summary.csv",
  row.names = FALSE
)

write.csv(
  species_summary,
  "species_prevalence_summary.csv",
  row.names = FALSE
)

# Show the most prevalent genera and species
head(genus_summary, 15)
head(species_summary, 20)

# Show taxa detected in only one sample
genus_unique <- genus_summary %>%
  filter(Prevalence == 1)

species_unique <- species_summary %>%
  filter(Prevalence == 1)

print(genus_unique)
print(species_unique)





# Top 5 taxa per sample
get_top_taxa <- function(mat, rank_name, n = 5) {
  
  result <- lapply(rownames(mat), function(sample_name) {
    
    abundances <- mat[sample_name, ]
    
    top_indices <- order(
      abundances, decreasing = TRUE
    )[seq_len(min(n, length(abundances)))]
    
    data.frame(
      Sample = sample_name,
      Rank = rank_name,
      Taxon = names(abundances)[top_indices],
      Relative_Abundance = as.numeric(
        abundances[top_indices]
      )
    )
  })
  
  bind_rows(result)
}

top5_genera_by_sample <- get_top_taxa(
  genus_tss, "Genus"
)

top5_species_by_sample <- get_top_taxa(
  species_tss, "Species"
)

write.csv(
  top5_genera_by_sample,
  "top5_genera_by_sample.csv",
  row.names = FALSE
)

write.csv(
  top5_species_by_sample,
  "top5_species_by_sample.csv",
  row.names = FALSE
)

print(top5_genera_by_sample)
print(top5_species_by_sample)





# Install once if needed:
# install.packages("vegan")

library(vegan)
library(pheatmap)

# Calculate Bray-Curtis dissimilarity
genus_bray <- vegdist(
  genus_tss,
  method = "bray"
)

species_bray <- vegdist(
  species_tss,
  method = "bray"
)

# Convert distance objects to matrices
genus_bray_mat <- as.matrix(genus_bray)
species_bray_mat <- as.matrix(species_bray)

# Genus-level sample similarity
pheatmap(
  genus_bray_mat,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  main = "Bray-Curtis dissimilarity: Genus",
  display_numbers = TRUE,
  filename = "genus_bray_curtis.png",
  width = 10,
  height = 9
)

# Species-level sample similarity
pheatmap(
  species_bray_mat,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  main = "Bray-Curtis dissimilarity: Species",
  display_numbers = TRUE,
  filename = "species_bray_curtis.png",
  width = 10,
  height = 9
)

