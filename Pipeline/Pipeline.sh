# Step0. QC and multiQC check samples' qualities
BASE=/NFSShare/Narwhal/metagenomic
for region in China ; do
  for fq in $BASE/Shotgun/$region/*.fastq.gz; do
    fastqc $fq -o $BASE/QC_fastqc/$region --threads 4
  done
done

for region in China ; do
  multiqc $BASE/QC_fastqc/* -o $BASE/QC_fastqc/*
done

# Step1. Install Kraken2: Kraken2 is the core tool used to classify the metagenomic reads by comparing them to a reference database of known microbial genomes.
cd /NFSShare/Narwhal/metagenomic/tool
git clone https://github.com/DerrickWood/kraken2.git
cd kraken2
./install_kraken2.sh /NFSShare/Narwhal/metagenomic/tool/kraken2_bin
export PATH=/NFSShare/Narwhal/metagenomic/tool/kraken2_bin:$PATH

# Step2. Download the Kraken2 database: The database contains microbial genome references that Kraken2 will use to classify your reads. 
mkdir -p /NFSShare/Narwhal/metagenomic/tool/kraken2_db
cd /NFSShare/Narwhal/metagenomic/tool/kraken2_db
curl -O https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20241228.tar.gz
curl -O https://genome-idx.s3.amazonaws.com/kraken/standard_08gb_20241228/inspect.txt
curl -O https://genome-idx.s3.amazonaws.com/kraken/standard_08gb_20241228/library_report.tsv
curl -O https://genome-idx.s3.amazonaws.com/kraken/standard_08gb_20241228/standard08gb.md5
tar -xvzf k2_standard_08gb_202305.tgz

# Step 3. Run Kraken2 on each sample (single-end R1 reads): This runs Kraken2 on your actual samples, classifying each read into a taxonomic group.
cd /NFSShare/Narwhal/metagenomic/Shotgun
mkdir -p ../kraken2_results
for region in China US; do
	for fq in $BASE/Shotgun/$region/*.fastq.gz; do
    	sample=$(basename $fq astq.gz)
    	kraken2 --db /NFSShare/Narwhal/metagenomic/tool/kraken2_db/ \
            --threads 8 \
            --report ../kraken2_results/${sample}_report.txt \
            --output ../kraken2_results/${sample}_output.txt \
            --use-names \
            --gzip-compressed \
            --single $fq
	done
done
