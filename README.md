## Microbiome_Metagenomics_full_pipeline
<img width="2048" height="768" alt="image" src="https://github.com/user-attachments/assets/df855c4b-286a-4666-994b-e9856c11b5c1" />

# question number 1 1. In this section you will perform an in initial quality check for the sequences using FastQC
# pipeline (this step can be done using windows system as well). Show the plots having the
# quality scores and add small snapshots for each sample. (5 marks)
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












# 🧬 Microbiome Metagenomics Full Pipeline

A step-by-step workflow for processing microbiome metagenomic sequencing data, from raw FASTQ files to quality control, read trimming, and taxonomic analysis.

<p align="center">
  <img width="100%" alt="Microbiome Metagenomics Pipeline" src="https://github.com/user-attachments/assets/df855c4b-286a-4666-994b-e9856c11b5c1" />
</p>

---

# Question 1: Initial Quality Check (5 Marks)

**Objective:** Perform an initial quality assessment of the raw sequencing reads using the FastQC pipeline. This step can also be performed on a Windows system. Display the quality score plots and include small snapshots for each sample.

## 1. Installing Miniconda on the SSH Client

Miniconda is used to manage the software environment and install the bioinformatics tools required for the analysis.

### Step 1.1: Download the Miniconda installer

Download the latest Miniconda installer for Linux:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

### Step 1.2: Run the installer

Execute the downloaded installation script:

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

Follow the instructions displayed in the terminal to complete the installation.

### Step 1.3: Initialize Conda

Reload the shell configuration:

```bash
source ~/.bashrc
```

Verify that Conda has been installed successfully:

```bash
conda --version
```

---

## 2. Setting Up the Bioinformatics Environment

Create a dedicated Conda environment named `assignment1` and install FastQC, Trimmomatic, and MultiQC.

### Step 2.1: Create the environment

```bash
conda create -n assignment1 \
    -c conda-forge \
    -c bioconda \
    fastqc trimmomatic multiqc -y
```

### Step 2.2: Activate the environment

```bash
conda activate assignment1
```

### Step 2.3: Verify the installations

Check the versions of the installed tools:

```bash
fastqc --version
trimmomatic -version
multiqc --version
```

**Installation verification**

The following screenshot shows the successful installation and version checks of the required bioinformatics tools.

<p align="center">
  <img width="800" alt="Conda environment and tool installation verification" src="https://github.com/user-attachments/assets/f11bc973-8b97-4443-ad68-e6fcfa74e76c" />
</p>

---

## 3. Initial Quality Assessment Using FastQC

FastQC is used to evaluate the quality of raw sequencing reads before any preprocessing. It generates quality control reports containing per-base quality scores, sequence quality distributions, GC content, adapter content, and other metrics.

### Step 3.1: Create an output directory

Create a directory to store the FastQC reports:

```bash
mkdir -p fastqc_raw
```

### Step 3.2: Run FastQC on raw reads

Run FastQC on all compressed FASTQ files located in the `raw` directory.

```bash
fastqc -t 4 \
    -o fastqc_raw \
    raw/*.fastq.gz
```

**Command explanation:**

| Parameter | Description |
|---|---|
| `-t 4` | Uses 4 threads for processing |
| `-o fastqc_raw` | Specifies the output directory |
| `raw/*.fastq.gz` | Processes all compressed FASTQ files in the raw data directory |

### Step 3.3: Verify the number of reports

Count the number of generated FastQC HTML reports:

```bash
ls fastqc_raw/*_fastqc.html | wc -l
```

**Expected output:**

```text
24
```

A total of 24 HTML reports are expected for the 24 raw FASTQ files.

---

## 4. Combining Reports Using MultiQC

MultiQC combines the individual FastQC reports into a single summary report, making it easier to compare quality metrics across all sequencing samples.

### Step 4.1: Generate the MultiQC report

Run MultiQC on the directory containing the FastQC results:

```bash
multiqc fastqc_raw -o multiqc_report
```

The combined report will be generated in the `multiqc_report` directory.

### Step 4.2: Verify the MultiQC output

Check that the report has been generated:

```bash
ls -lh multiqc_report/multiqc_report.html
```

Download or open the generated HTML report to inspect the quality metrics across all samples.

---

## 5. Results and Quality Control

The initial quality assessment produces individual FastQC reports and a combined MultiQC report for all 24 raw FASTQ files.

### Key quality metrics to examine

- **Per-base sequence quality:** Evaluates the quality scores of bases across each sequencing read.
- **Per-sequence quality scores:** Shows the distribution of average quality scores across reads.
- **Per-base sequence content:** Examines the relative proportions of A, T, G, and C at each base position.
- **GC content:** Evaluates the GC distribution of the reads.
- **Adapter content:** Checks for the presence of sequencing adapters.
- **Sequence length distribution:** Shows the distribution of read lengths.

### Screenshots of the results

Add the FastQC plots for individual samples and screenshots of the MultiQC summary below this section.

<!--
Example:
<p align="center">
  <img width="700" src="PATH_TO_FASTQC_PLOT" alt="FastQC per-base sequence quality plot" />
</p>
-->

---

**Output directory structure**

```text
Microbiome_Metagenomics_full_pipeline/
│
├── raw/
│   ├── sample1_R1.fastq.gz
│   ├── sample1_R2.fastq.gz
│   └── ...
│
├── fastqc_raw/
│   ├── sample1_R1_fastqc.html
│   ├── sample1_R1_fastqc.zip
│   ├── sample1_R2_fastqc.html
│   ├── sample1_R2_fastqc.zip
│   └── ...
│
└── multiqc_report/
    └── multiqc_report.html
```
```

combined the report in multiqc 
```bash
multiqc fastqc_raw -o fastqc_raw
```
