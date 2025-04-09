# Load required library
# If not installed, run: install.packages("ggplot2")
library(ggplot2)

# Step 1: Read data
# This file contains species as rows and samples as columns
df <- read.delim("/Users/joyce/Documents/UT-Austin/Courses/Bioinformatics/Project/Results/PCA/species_abundance_matrix.tsv",
                 row.names = 1, check.names = FALSE)

# Step 2: Transpose the matrix so that samples are rows
data_t <- t(df)

# Step 3: Remove samples (rows) with zero variance
data_t_filtered <- data_t[apply(data_t, 1, function(x) sd(x) > 0), ]

# Step 4: Remove features (columns) with zero variance
data_t_filtered <- data_t_filtered[, apply(data_t_filtered, 2, function(x) sd(x) > 0)]

# Step 5: Define sample groups
us_samples <- c("SRR18691629", "SRR18691630", "SRR18691631", "SRR18691634",
                "SRR18691633", "SRR18691637", "SRR18691635", "SRR18691638",
                "SRR18691636", "SRR18691632")

china_samples <- c("ERR9538591_1", "ERR9530653_1", "ERR9530651_1", "ERR9538571_1",
                   "ERR9538620_1", "ERR9538697_1", "ERR9538699_1", "ERR9538449_1",
                   "ERR9538693_1", "ERR9538594_1")

# Step 6: Assign sample group labels
group <- ifelse(rownames(data_t_filtered) %in% us_samples, "US",
                ifelse(rownames(data_t_filtered) %in% china_samples, "China", "Other"))

# Step 7: Perform PCA with scaling
pca_res <- prcomp(data_t_filtered, scale. = TRUE)

# Step 8: Create data frame for plotting
pca_df <- as.data.frame(pca_res$x)
pca_df$Group <- group

# Step 9: Draw PCA plot
ggplot(pca_df, aes(x = PC1, y = PC2, color = Group)) +
  geom_point(size = 3) +
  stat_ellipse(aes(group = Group), linetype = "dashed") +
  theme_minimal() +
  labs(
    title = "PCA of Species Abundance",
    x = paste0("PC1 (", round(summary(pca_res)$importance[2, 1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(summary(pca_res)$importance[2, 2] * 100, 1), "%)")
  )+ theme(plot.title = element_text(hjust = 0.5))

