## Microbiome_Metagenomics_full_pipeline
<img width="2048" height="768" alt="image" src="https://github.com/user-attachments/assets/df855c4b-286a-4666-994b-e9856c11b5c1" />

# question number 1
installing the mini conda in our ssh clint 
Download the Miniconda installer:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

Run the installer:

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

```bash
source ~/.bashrc
```
Verify the installation:

```bash
conda --version
```

```bash
conda create -n assignment1 -c conda-forge -c bioconda fastqc trimmomatic multiqc -y
```

```bash
conda activate assignment1
```
```bash
fastqc --version
trimmomatic -version
multiqc --version
```


<img width="800" height="188" alt="image" src="https://github.com/user-attachments/assets/f11bc973-8b97-4443-ad68-e6fcfa74e76c" />


Run FastQC on raw reads
```bash
mkdir -p fastqc_raw

fastqc -t 4 \
    -o fastqc_raw \
    raw/*.fastq.gz
```
Checking it should give 24 as output
```bash
ls fastqc_raw/*_fastqc.html | wc -l
```

combined the report in multiqc 
```bash
multiqc fastqc_raw -o fastqc_raw
```
