import pandas as pd

# Load Kraken2 report
for num in range(29, 39): 
    file_path = f"/Users/joyce/Documents/UT-Austin/Courses/Bioinformatics/Project/Results/kraken2_results/SRR186916{num}.f_report.txt"

# Read as tab-separated values with no header
    df = pd.read_csv(file_path, sep="\t", header=None, names=[
    "percentage", "reads_clade", "reads_direct", "rank_code", "taxonomy_id", "name"
])

# Trim spaces in names
    df["name"] = df["name"].str.strip()

# Filter to keep only species-level rows (rank_code == 'S')
    species_df = df[df["rank_code"] == "S"].copy()

# Recalculate relative abundance (species-only total)
    total_species_reads = species_df["reads_clade"].sum()
    species_df["recalculated_percent"] = (species_df["reads_clade"] / total_species_reads) * 100

# Sort by descending abundance
    species_df = species_df.sort_values(by="recalculated_percent", ascending=False)

# Keep only useful columns
    species_df_clean = species_df[["name", "reads_clade", "recalculated_percent"]]

# Output to CSV
    species_df_clean.to_csv(f"/Users/joyce/Documents/UT-Austin/Courses/Bioinformatics/Project/Results/kraken2_results/new/SRR186916{num}_species.csv", index=False)

# Optional: Print top 10 species
    print(species_df_clean.head(10))



