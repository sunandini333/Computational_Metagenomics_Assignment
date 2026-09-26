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

## 1. Run Trimmomatic on All 12 Samples

**Objective:** Perform quality trimming of the paired-end sequencing reads using Trimmomatic 0.41 with the following parameters:

- `SLIDINGWINDOW:5:27`
- `MINLEN:100`
- `AVGQUAL:27`

Trimmomatic removes low-quality bases and filters out reads that do not meet the specified quality thresholds. The paired-end reads are processed for all 12 samples, and the trimming logs are saved for further analysis.

### Step 1.1: Navigate to the Assignment Directory

Navigate to the `Assignment1` directory and activate the Conda environment containing Trimmomatic.

```bash
cd ~/comeg_asg1/Assignment1
conda activate assignment1
```

### Step 1.2: Create Output Directories

Create separate directories for the trimmed reads and the Trimmomatic log files.

```bash
mkdir -p trimmed results
```

### Step 1.3: Run Trimmomatic on All Samples

The following shell script automatically identifies the forward and reverse FASTQ files for each sample, performs paired-end quality trimming, and saves the output files and logs.

```bash
set -o pipefail

for f1 in raw/*_1.fastq.gz; do
    sample=$(basename "$f1" _1.fastq.gz)
    f2="raw/${sample}_2.fastq.gz"

    if [ ! -f "$f2" ]; then
        echo "ERROR: Missing reverse read for $sample"
        continue
    fi

    echo "===================================="
    echo "Trimming sample: $sample"
    echo "===================================="

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

    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        echo "ERROR: Trimmomatic failed for $sample"
    fi
done
```

### Trimming Parameters

| Parameter | Description |
|---|---|
| `PE` | Runs Trimmomatic in paired-end mode |
| `-threads 4` | Uses 4 threads for processing |
| `-phred33` | Specifies Phred+33 quality encoding |
| `SLIDINGWINDOW:5:27` | Scans a sliding window of 5 bases and trims when the average quality falls below 27 |
| `MINLEN:100` | Discards reads shorter than 100 bases |
| `AVGQUAL:27` | Discards reads with an average quality score below 27 |
| `tee` | Displays the trimming output and saves it to a log file |
| `set -o pipefail` | Allows pipeline failures to be detected |

### Output Files

For each sample, Trimmomatic generates four output files:

1. **Forward paired:** Forward reads whose corresponding reverse reads also survive filtering.
2. **Forward unpaired:** Forward reads that survive filtering but whose reverse mates do not.
3. **Reverse paired:** Reverse reads whose corresponding forward reads also survive filtering.
4. **Reverse unpaired:** Reverse reads that survive filtering but whose forward mates do not.

Each sample also generates a separate log file containing the trimming statistics.

---

## 2. Verify That Trimming Succeeded

After the trimming process is complete, verify that all 12 samples have generated their expected paired-end output files and log files.

### Step 2.1: Count the Paired Forward Reads

```bash
echo "Paired forward reads:"
ls trimmed/*_1_paired.fastq.gz | wc -l
```

### Step 2.2: Count the Paired Reverse Reads

```bash
echo "Paired reverse reads:"
ls trimmed/*_2_paired.fastq.gz | wc -l
```

### Step 2.3: Count the Trimming Logs

```bash
echo "Trimming logs:"
ls results/*_trimmomatic.log | wc -l
```

### Expected Output

If all 12 samples are processed successfully, the expected file counts are:

| Output | Expected Number |
|---|---:|
| Forward paired files | 12 |
| Reverse paired files | 12 |
| Trimming log files | 12 |

**Note:** If fewer files are generated, check the relevant Trimmomatic log for errors before proceeding to downstream analysis.
![Uploading image.png…]()


---

## 3. Summarize the Trimming Results

Trimmomatic generates a summary for each sample, including the number of input read pairs, surviving paired reads, surviving individual reads, and dropped reads.

### Step 3.1: Extract Trimming Statistics

Run the following command to extract the key statistics from all 12 log files:

```bash
grep -hE \
'Input Read Pairs|Both Surviving|Forward Only Surviving|Reverse Only Surviving|Dropped' \
results/*_trimmomatic.log
```

### Step 3.2: Understand the Trimming Statistics

| Statistic | Description |
|---|---|
| Input Read Pairs | Total number of forward and reverse read pairs processed |
| Both Surviving | Number of pairs in which both reads survived quality filtering |
| Forward Only Surviving | Number of pairs in which only the forward read survived |
| Reverse Only Surviving | Number of pairs in which only the reverse read survived |
| Dropped | Number of pairs in which neither read survived filtering |

### Step 3.3: Record the Results

Use the actual values extracted from the Trimmomatic logs to complete the following table for the report.

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

*Replace the dashes with the actual statistics from the corresponding log files. Adjust the sample IDs if your filenames differ.*

---

## 4. Infer the Trimming Results

The trimming statistics can be used to evaluate the effect of quality filtering on the sequencing reads.

### 4.1 Calculate the Paired Read Retention

The percentage of read pairs in which both reads survived trimming can be calculated using the following formula:

\[
\text{Paired Retention (\%)} =
\frac{\text{Both Surviving Pairs}}
{\text{Input Read Pairs}} \times 100
\]

### 4.2 Calculate the Percentage of Dropped Read Pairs

\[
\text{Dropped (\%)} =
\frac{\text{Dropped Read Pairs}}
{\text{Input Read Pairs}} \times 100
\]

### 4.3 Discussion and Interpretation

Compare the trimming statistics across all 12 samples and discuss the following:

1. **Read retention:** Identify the number and percentage of read pairs in which both reads survived filtering.
2. **Read loss:** Compare the number of dropped read pairs across samples and identify any substantial differences.
3. **Single surviving reads:** Examine the number of forward-only and reverse-only surviving reads.
4. **Effect of filtering parameters:** Discuss how the sliding-window quality threshold, minimum read length, and average quality threshold affect read retention.
5. **Downstream analysis:** Explain how the resulting high-quality paired reads will be used for taxonomic classification with SPINGO.

Use the actual trimming statistics to support your interpretation. Do not assume that every sample has the same read retention rate.

---

## 5. Final Output Directory Structure

The trimmed reads and their corresponding logs are stored in the following directories:

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
└── ...
```

---

## 6. Conclusion

Trimmomatic 0.41 was used to perform quality trimming of 12 paired-end sequencing samples with the specified parameters: `SLIDINGWINDOW:5:27`, `MINLEN:100`, and `AVGQUAL:27`.

The resulting paired and unpaired reads were saved in the `trimmed/` directory, while individual trimming logs were saved in `results/`. The trimming statistics provide information about read retention, single surviving reads, and read loss, which can be used to evaluate the quality-filtering results before downstream taxonomic classification.
