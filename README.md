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
Assignment1/
│
├── raw/
│   ├── SR14919235_1.fastq.gz
│   ├── SR14919235_2.fastq.gz
│   └── ...
│
├── fastqc_raw/
│   ├── SR14919235_1_fastqc.html
│   ├── SR14919235_1_fastqc.zip
│   ├── SR14919235_2_fastqc.html
│   ├── SR14919235_2_fastqc.zip
│   ├── ...
│   ├── multiqc_data/
│   └── multiqc_report.html
│
├── trimmed/
├── fastqc_trimmed/
├── spingo/
└── results/
```

---

# Question 2: Quality Trimming Using Trimmomatic (5 Marks)

**Objective:** Perform quality trimming of the paired-end sequencing reads using Trimmomatic with the specified parameters:

- `SLIDINGWINDOW:5:27`
- `MINLEN:100`
- `AVGQUAL:27`

The trimming process removes low-quality bases and short reads to obtain high-quality reads for downstream taxonomic classification.

## 1. Running Trimmomatic on Paired-End Samples

Trimmomatic is used to trim low-quality bases from the raw sequencing reads. The following loop processes all 12 paired-end samples in the `raw/` directory and saves the paired and unpaired reads separately.

### Step 1.1: Create output directories

Create directories to store the trimmed reads and Trimmomatic log files.

```bash
mkdir -p trimmed results
```

### Step 1.2: Run Trimmomatic on all 12 samples

The following shell script automatically identifies the forward and reverse reads for each sample, performs quality trimming, and captures the trimming statistics in individual log files.

```bash
set -o pipefail

for f1 in raw/*_1.fastq.gz; do
    sample=$(basename "$f1" _1.fastq.gz)
    f2="raw/${sample}_2.fastq.gz"

    echo "Processing $sample"

    trimmomatic PE \
        -threads 4 \
        -phred33 \
        "$f1" "$f2" \
        "trimmed/${sample}_1_paired.fastq.gz" \
        "trimmed/${sample}_1_unpaired.fastq.gz" \
        "trimmed/${sample}_2_paired.fastq.gz" \
        "trimmed/${sample}_2_unpaired.fastq.gz" \
        SLIDINGWINDOW:5:27 \
        MINLEN:100 \
        AVGQUAL:27 \
        2>&1 | tee "results/${sample}_trimmomatic.log"

    if [ $? -ne 0 ]; then
        echo "Trimming failed for $sample"
        exit 1
    fi
done
```

### Command explanation

| Command / Option | Description |
|---|---|
| `trimmomatic PE` | Runs Trimmomatic in paired-end mode |
| `-threads 4` | Uses 4 CPU threads |
| `-phred33` | Specifies Phred+33 quality encoding |
| `SLIDINGWINDOW:5:27` | Scans a sliding window of 5 bases and trims when the average quality falls below 27 |
| `MINLEN:100` | Discards reads shorter than 100 bases |
| `AVGQUAL:27` | Discards reads whose average quality score is below 27 |
| `tee` | Displays the log in the terminal and saves it to a file |
| `set -o pipefail` | Ensures pipeline failures are detected |

### Output files

For each sample, Trimmomatic generates four output files:

1. **Forward paired reads:** High-quality forward reads whose reverse mates also survive filtering.
2. **Forward unpaired reads:** Forward reads that survive filtering but whose reverse mates do not.
3. **Reverse paired reads:** High-quality reverse reads whose forward mates also survive filtering.
4. **Reverse unpaired reads:** Reverse reads that survive filtering but whose forward mates do not.

---

## 2. Verifying the Trimmed Read Files

After trimming all 12 paired-end samples, verify that the expected paired-end output files have been generated.

### Step 2.1: Count paired reads files

```bash
ls trimmed/*_paired.fastq.gz | wc -l
```

**Expected output:**

```text
24
```

This corresponds to 12 forward paired files and 12 reverse paired files.

![Uploading image.png…]()


### Step 2.2: Count all trimmed output files

```bash
ls trimmed/*.fastq.gz | wc -l
```

**Expected output:**

```text
48
```

This includes the paired and unpaired outputs for all 12 samples, assuming all four output files are generated for every sample.

---

## 3. Recording Trimming Statistics

Trimmomatic produces a summary of the number of input read pairs, surviving paired reads, surviving individual reads, and dropped reads.

The `results/` directory contains a separate log file for each sample.

### Step 3.1: Extract trimming statistics

Use the following command to extract the key trimming statistics from all 12 log files.

```bash
grep -E \
'Input Read Pairs|Both Surviving|Forward Only Surviving|Reverse Only Surviving|Dropped' \
results/*_trimmomatic.log
```

### Step 3.2: Interpret the trimming statistics

The following statistics should be recorded for each sample:

| Statistic | Description |
|---|---|
| Input Read Pairs | Total number of read pairs processed |
| Both Surviving | Number of pairs in which both forward and reverse reads survived |
| Forward Only Surviving | Number of pairs in which only the forward read survived |
| Reverse Only Surviving | Number of pairs in which only the reverse read survived |
| Dropped | Number of pairs in which neither read survived |

### Step 3.3: Summary table

Use the extracted values from the Trimmomatic logs to complete the following table in your report.

| Sample | Input Read Pairs | Both Surviving | Forward Only | Reverse Only | Dropped |
|---|---:|---:|---:|---:|---:|
| SR14919235 | — | — | — | — | — |
| SR14919236 | — | — | — | — | — |
| SR14919237 | — | — | — | — | — |
| SR14919238 | — | — | — | — | — |
| SR14919239 | — | — | — | — | — |
| SR14919240 | — | — | — | — | — |
| SR14919241 | — | — | — | — | — |
| SR14919242 | — | — | — | — | — |
| SR14919243 | — | — | — | — | — |
| SR14919244 | — | — | — | — | — |
| SR14919245 | — | — | — | — | — |
| SR14919246 | — | — | — | — | — |

**Note:** Replace the dashes with the actual values from your Trimmomatic log files.

---

## 4. Inferring the Trimming Results

The trimming statistics can be used to evaluate the effect of quality filtering on the sequencing reads.

Discuss the following points based on your actual results:

- **Read retention:** Calculate the percentage of read pairs in which both reads survived quality trimming.
- **Read loss:** Identify samples with relatively high numbers of dropped read pairs.
- **Single surviving reads:** Compare the number of forward-only and reverse-only surviving reads across samples.
- **Effect of quality filtering:** Explain how the selected quality thresholds and minimum read length affect the number of reads available for downstream analysis.

### Read retention calculation

The percentage of read pairs in which both reads survived can be calculated as:

\[
\text{Retention (\%)} =
\frac{\text{Both Surviving}}{\text{Input Read Pairs}}
\times 100
\]

The percentage of dropped read pairs can be calculated as:

\[
\text{Dropped (\%)} =
\frac{\text{Dropped}}{\text{Input Read Pairs}}
\times 100
\]

Use these calculations to compare the samples and discuss the observed trimming outcomes.

---

## 5. Final Output Directory Structure

The following directory structure shows where the trimmed reads and trimming logs are stored.

```text
Assignment1/
│
├── raw/
│   ├── SR14919235_1.fastq.gz
│   ├── SR14919235_2.fastq.gz
│   └── ...
│
├── fastqc_raw/
│   ├── ..._fastqc.html
│   ├── ..._fastqc.zip
│   ├── multiqc_data/
│   └── multiqc_report.html
│
├── trimmed/
│   ├── SR14919235_1_paired.fastq.gz
│   ├── SR14919235_1_unpaired.fastq.gz
│   ├── SR14919235_2_paired.fastq.gz
│   ├── SR14919235_2_unpaired.fastq.gz
│   └── ...
│
├── results/
│   ├── SR14919235_trimmomatic.log
│   ├── SR14919236_trimmomatic.log
│   └── ...
│
├── fastqc_trimmed/
├── spingo/
└── results/
```

---

## 6. Conclusion

Trimmomatic was used to perform quality trimming of the 12 paired-end sequencing samples using the specified quality thresholds and minimum read length. The resulting paired and unpaired reads were saved in the `trimmed/` directory, while individual trimming logs were stored in the `results/` directory.

The number of surviving and dropped reads should be compared across samples to assess the effect of the filtering parameters and determine the availability of high-quality reads for downstream analysis.
