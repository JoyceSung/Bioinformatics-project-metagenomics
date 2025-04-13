import os
import pandas as pd
from glob import glob

# Folder containing all _report.txt files
input_dir = "/Users/joyce/Documents/UT-Austin/Courses/Bioinformatics/Project/Results/kraken2_results"
output_file = "/Users/joyce/Documents/UT-Austin/Courses/Bioinformatics/Project/Results/PCA/species_abundance_matrix.tsv"

# Extract lines at species level from each report
abundance_data = {}

for file in glob(os.path.join(input_dir, "*.f_report.txt")):
    sample_name = os.path.basename(file).replace(".f_report.txt", "")
    abundance_data[sample_name] = {}
    
    with open(file, "r") as f:
        for line in f:
            parts = line.strip().split("\t")
            tax_level = parts[3].strip()
            name = parts[5].strip()
            count = int(parts[2])
            
            # Only keep species-level entries (S)
            if tax_level == "S":
                abundance_data[sample_name][name] = count

# Convert to DataFrame
abundance_df = pd.DataFrame.from_dict(abundance_data, orient="index").fillna(0).astype(int)
abundance_df.T.to_csv(output_file, sep="\t")
print(f"✅ Abundance matrix saved as: {output_file}")
