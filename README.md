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

<img width="560" height="305" alt="image" src="https://github.com/user-attachments/assets/2bbdc84d-1390-446e-ab32-1268c8c3e4a7" />



**Note:** If fewer files are generated, check the relevant Trimmomatic log for errors before proceeding to downstream analysis.




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


<img width="662" height="356" alt="image" src="https://github.com/user-attachments/assets/ab550aa5-9351-4792-a44b-6ecc0d9bbe57" />


### Step 3.2: Understand the Trimming Statistics

| Statistic | Description |
|---|---|
| Input Read Pairs | Total number of forward and reverse read pairs processed |
| Both Surviving | Number of pairs in which both reads survived quality filtering |
| Forward Only Surviving | Number of pairs in which only the forward read survived |
| Reverse Only Surviving | Number of pairs in which only the reverse read survived |
| Dropped | Number of pairs in which neither read survived filtering |


<img width="725" height="77" alt="image" src="https://github.com/user-attachments/assets/174ab46b-0928-4565-beb8-b09edaab7537" />


<img width="952" height="98" alt="image" src="https://github.com/user-attachments/assets/cf61eb04-a67d-4ea4-9d9c-c17137194368" />


### Step 3.3: Extract and Summarize Trimming Statistics

Run the following command to display the Trimmomatic statistics for all 12 samples:

```bash
for f in results/*_trimmomatic.log; do
    echo "=== $(basename "$f" _trimmomatic.log) ==="
    grep "Input Read Pairs" "$f"
done
```

<img width="656" height="423" alt="image" src="https://github.com/user-attachments/assets/7a5600a3-9d60-4961-aaab-266a8d2db74a" />


### Trimming Statistics

| Sample | Input Read Pairs | Both Surviving | Forward Only | Reverse Only | Dropped |
|---|---:|---:|---:|---:|---:|
| SRR14919235 | 135,499 | 133,906 (98.82%) | 1,422 (1.05%) | 136 (0.10%) | 35 (0.03%) |
| SRR14919236 | 198,249 | 195,509 (98.62%) | 2,503 (1.26%) | 185 (0.09%) | 52 (0.03%) |
| SRR14919237 | 103,416 | 102,290 (98.91%) | 1,013 (0.98%) | 90 (0.09%) | 23 (0.02%) |
| SRR14919238 | 145,514 | 143,704 (98.76%) | 1,624 (1.12%) | 157 (0.11%) | 29 (0.02%) |
| SRR14919239 | 132,914 | 131,234 (98.74%) | 1,512 (1.14%) | 129 (0.10%) | 39 (0.03%) |
| SRR14919240 | 163,766 | 161,812 (98.81%) | 1,760 (1.07%) | 162 (0.10%) | 32 (0.02%) |
| SRR14919241 | 189,869 | 188,123 (99.08%) | 1,508 (0.79%) | 208 (0.11%) | 30 (0.02%) |
| SRR14919242 | 185,794 | 183,683 (98.86%) | 1,874 (1.01%) | 201 (0.11%) | 36 (0.02%) |
| SRR14919243 | 157,597 | 156,078 (99.04%) | 1,329 (0.84%) | 161 (0.10%) | 29 (0.02%) |
| SRR14919244 | 151,447 | 149,739 (98.87%) | 1,519 (1.00%) | 161 (0.11%) | 28 (0.02%) |
| SRR14919245 | 151,024 | 149,268 (98.84%) | 1,582 (1.05%) | 136 (0.09%) | 38 (0.03%) |
| SRR14919246 | 123,516 | 122,214 (98.95%) | 1,128 (0.91%) | 138 (0.11%) | 36 (0.03%) |


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


## 5. Quality Assessment of Trimmed Reads Using FastQC

After completing quality trimming with Trimmomatic, FastQC is used again to evaluate the quality of the retained paired-end reads. The results are then combined using MultiQC to assess the overall quality of the trimmed data.

### Step 5.1: Navigate to the Assignment Directory

Navigate to the project directory and activate the Conda environment.

```bash
cd ~/comeg_asg1/Assignment1
conda activate assignment1
```

### Step 5.2: Create the Output Directory

Create a separate directory to store the FastQC reports generated from the trimmed reads.

```bash
mkdir -p fastqc_trimmed
```

### Step 5.3: Run FastQC on the Trimmed Paired Reads

Run FastQC on all 24 paired output files generated by Trimmomatic (12 forward and 12 reverse reads).

```bash
fastqc -t 4 \
    -o fastqc_trimmed \
    trimmed/*_paired.fastq.gz
```

**Command explanation:**

| Parameter | Description |
|---|---|
| `-t 4` | Uses 4 threads for processing |
| `-o fastqc_trimmed` | Specifies the output directory |
| `trimmed/*_paired.fastq.gz` | Selects all paired-end trimmed FASTQ files |

### Step 5.4: Generate the Combined MultiQC Report

Combine the individual FastQC reports into a single summary report using MultiQC.

```bash
multiqc fastqc_trimmed -o fastqc_trimmed
```

The combined report and its supporting data will be saved in the same directory as the individual FastQC reports.

### Step 5.5: Verify the FastQC and MultiQC Outputs

Count the number of generated FastQC HTML reports:

```bash
find fastqc_trimmed -maxdepth 1 \
    -name '*_fastqc.html' | wc -l
```

**Expected output:**

```text
24
```

Verify that the combined MultiQC report has been generated:

```bash
ls -lh fastqc_trimmed/multiqc_report.html
```

**Expected output:** The command should display the file details for `multiqc_report.html`.

If all 24 paired reads were processed successfully, there should be 24 individual FastQC HTML reports and one combined MultiQC report.

---

## 6. Comparison of Raw and Trimmed Quality Reports

The quality of the raw sequencing reads and the trimmed reads is compared using the MultiQC reports generated in the previous steps.

### Step 6.1: Open the MultiQC Reports

Open the following reports in a web browser:

| Dataset | MultiQC Report |
|---|---|
| Raw reads | `fastqc_raw/multiqc_report.html` |
| Trimmed paired reads | `fastqc_trimmed/multiqc_report.html` |

These reports provide a summary of the quality metrics across all samples before and after trimming.

### Step 6.2: Compare the Quality Metrics

Compare the following quality metrics between the raw and trimmed reads:

| Quality Metric | Raw Reads | Trimmed Reads |
|---|---|---|
| Per-base sequence quality | Assess the original base quality scores across read positions | Examine whether low-quality bases have been removed |
| Per-sequence quality scores | Evaluate the distribution of average read quality | Assess the distribution after filtering |
| Sequence length distribution | Examine the original read lengths | Observe the read lengths remaining after trimming |
| Per-base sequence content | Check for variations in nucleotide composition | Examine any changes in nucleotide composition |
| Adapter content | Identify any adapter contamination | Check whether adapter contamination remains |
| FastQC warnings | Record the quality warnings in the raw data | Compare the warnings after trimming |

### Step 6.3: Interpretation of the Results

Use the two MultiQC reports to discuss the effects of quality trimming.

Consider the following points:

1. **Per-base sequence quality:** Determine whether the quality scores of the retained reads have improved, particularly toward the ends of the reads.
2. **Read length distribution:** Compare the original read lengths with the trimmed read lengths and identify any reduction caused by trimming and minimum-length filtering.
3. **Sequence quality warnings:** Compare the FastQC warnings and identify which quality issues have improved, persisted, or changed after trimming.
4. **Read retention:** Relate the observed quality improvements to the read retention statistics obtained from the Trimmomatic logs.
5. **Downstream suitability:** Discuss whether the trimmed paired reads are suitable for subsequent taxonomic classification using SPINGO.

**Note:** Trimming does not necessarily eliminate every FastQC warning. Interpret the results using the actual plots and quality metrics rather than assuming that every metric will pass after trimming.

### Step 6.4: Screenshots of the Quality Reports

Include screenshots from both MultiQC reports to illustrate the changes in quality before and after trimming.

Suggested plots to include:

- Per-base sequence quality plots for representative samples.
- Sequence length distribution before and after trimming.
- Per-sequence quality score distributions.
- Relevant FastQC warning summaries.

---

## 7. Final Output Directory Structure

The final directory structure for Question 2 includes the trimmed FASTQ files, individual Trimmomatic logs, and FastQC and MultiQC reports for both raw and trimmed reads.

```text
Assignment1/
│
├── raw/
│   ├── SR14919235_1.fastq.gz
│   ├── SR14919235_2.fastq.gz
│   └── ...
│
├── fastqc_raw/
│   ├── *_fastqc.html
│   ├── *_fastqc.zip
│   ├── multiqc_data/
│   └── multiqc_report.html
│
├── trimmed/
│   ├── *_1_paired.fastq.gz
│   ├── *_1_unpaired.fastq.gz
│   ├── *_2_paired.fastq.gz
│   ├── *_2_unpaired.fastq.gz
│   └── ...
│
├── results/
│   ├── SR14919235_trimmomatic.log
│   ├── SR14919236_trimmomatic.log
│   └── ...
│
├── fastqc_trimmed/
│   ├── *_fastqc.html
│   ├── *_fastqc.zip
│   ├── multiqc_data/
│   └── multiqc_report.html
│
├── spingo/
└── ...
```

---

## 8. Conclusion

Quality trimming was performed on all 12 paired-end samples using Trimmomatic 0.41 with the specified quality thresholds. The resulting paired and unpaired reads were saved in the `trimmed/` directory, and the trimming statistics were recorded in individual log files.

FastQC was subsequently used to assess the quality of the trimmed paired reads, and MultiQC was used to combine the reports. Comparing the raw and trimmed quality reports helps evaluate the effect of trimming on base quality, read length, and quality-control warnings before proceeding to downstream taxonomic classification.






# Question 3: Taxonomic Classification Using SPINGO (5 Marks)

## 1. Objective

Classify the sequencing reads at both genus and species levels using the SPINGO pipeline. Calculate the relative abundances of the identified species using total-sum scaling (TSS) normalization. Identify the top 20 species based on their mean relative abundance and visualize their abundances using sorted bar graphs.

The workflow consists of the following steps:

1. Prepare the SPINGO pipeline and its reference database.
2. Configure the SPINGO Perl script to use the local installation.
3. Perform taxonomic classification of the sequencing reads.
4. Calculate species-level relative abundances using TSS normalization.
5. Identify the top 20 species based on mean abundance.
6. Generate sorted bar graphs to visualize the results.

---

## 2. Set Up the SPINGO Environment

### Step 2.1: Navigate to the Assignment Directory

Navigate to the project directory and activate the Conda environment.

```bash
cd ~/comeg_asg1/Assignment1
conda activate assignment1
```

### Step 2.2: Inspect the SPINGO Script

The provided Perl script, `double_end_spingo.pl`, is used to run SPINGO on the paired-end sequencing samples.

Inspect the beginning of the script:

```bash
head double_end_spingo.pl
```

Before making any modifications, create a backup of the original script.

```bash
cp double_end_spingo.pl double_end_spingo_original.pl
```

The original script is preserved as `double_end_spingo_original.pl`, allowing the initial version to be recovered if required.

---

## 3. Configure the SPINGO Script

The original script contains paths from the professor's server. These paths must be replaced with the paths to the local SPINGO executable and reference database.

### Step 3.1: Open the Perl Script

Open the script using the Nano text editor:

```bash
nano double_end_spingo.pl
```

<img width="520" height="377" alt="image" src="https://github.com/user-attachments/assets/6ed46b8c-e2f0-4d08-a6e6-c8f9bbf076f6" />


### Step 3.2: Define the SPINGO Executable and Database Paths

Locate the `use strict;` statement near the beginning of the script.

Immediately after that statement, add the following two variables:

```perl
my $SPINGO = "$ENV{HOME}/comeg_asg1/Assignment1/SPINGO-master/spingo";
my $DB = "$ENV{HOME}/comeg_asg1/Assignment1/SPINGO-master/database/RDP_11.2.species.fa";
```

The beginning of the modified script should look like this:

```perl
use strict;

my $SPINGO = "$ENV{HOME}/comeg_asg1/Assignment1/SPINGO-master/spingo";
my $DB = "$ENV{HOME}/comeg_asg1/Assignment1/SPINGO-master/database/RDP_11.2.species.fa";

open(LIST, "$ARGV[0]");
while(<LIST>)
{
```

These variables define the locations of the SPINGO executable and the RDP 11.2 species reference database.

### Step 3.3: Replace the Original SPINGO Command

Locate the existing SPINGO execution command in the script. It begins with the professor's original server path:

```perl
system("/home/sourav_g/spingo/SPINGO-master/spingo
```

Replace the entire original command line with:

```perl
system("$SPINGO -d $DB -p 4 -i $fa > $sample.spingo.out.txt");
```

**Command explanation:**

| Option | Description |
|---|---|
| `$SPINGO` | Path to the local SPINGO executable |
| `-d $DB` | Specifies the reference database |
| `-p 4` | Uses 4 processing threads |
| `-i $fa` | Specifies the input FASTA file |
| `> $sample.spingo.out.txt` | Redirects the classification output to a sample-specific text file |

This modification allows the script to run using the local SPINGO installation instead of the original server paths.

### Step 3.4: Save the Modified Script

After making the changes in Nano:

1. Press `Ctrl + O` to save the file.
2. Press `Enter` to confirm the filename.
3. Press `Ctrl + X` to exit Nano.

---

## 4. Validate the Modified Perl Script

Before running the classification pipeline, check the syntax of the modified Perl script.

Execute:

```bash
perl -c double_end_spingo.pl
```

If the script is syntactically correct, the terminal should display:

```text
double_end_spingo.pl syntax OK
```

This confirms that Perl can parse the script without syntax errors. It does not, by itself, confirm that the SPINGO executable, reference database, input files, or classification commands will run successfully.

---

## 5. SPINGO Classification

After validating the modified script, proceed with taxonomic classification using the paired-end sequencing reads.

The classification is performed using the SPINGO executable and the RDP 11.2 species reference database. The script accepts the input file list through its first command-line argument, as indicated by:

```perl
open(LIST, "$ARGV[0]");
```

Each input entry is processed by the script, and its SPINGO output is written to a sample-specific text file.

**Note:** The exact command to launch the complete classification run depends on the format and filename of the input list and on the remaining input-handling logic in `double_end_spingo.pl`. Use the input list and invocation specified in the supplied assignment script.

---

## 6. Relative Abundance Calculation and TSS Normalization

After obtaining the taxonomic classification results, calculate the abundance of each species in each sample.

Total-sum scaling (TSS) normalization converts the raw species counts into relative abundances by dividing each species count by the total number of classified reads in that sample.

The relative abundance of species \(i\) in sample \(j\) is:

\[
RA_{ij} = \frac{C_{ij}}{\sum_{i=1}^{S} C_{ij}}
\]

Where:

- \(RA_{ij}\) is the relative abundance of species \(i\) in sample \(j\).
- \(C_{ij}\) is the raw count of species \(i\) in sample \(j\).
- \(S\) is the total number of species in the abundance table.

For relative abundance expressed as a percentage:

\[
RA_{ij}(\%) =
\frac{C_{ij}}{\sum_{i=1}^{S} C_{ij}} \times 100
\]

Each sample's relative abundance values should sum to 1, or 100% when expressed as percentages, provided the sample has a nonzero total classified count.

---

## 7. Identify the Top 20 Species

Calculate the mean relative abundance of each species across the samples after TSS normalization.

The mean relative abundance of species \(i\) is:

\[
\overline{RA_i} =
\frac{1}{N}\sum_{j=1}^{N}RA_{ij}
\]

Where:

- \(\overline{RA_i}\) is the mean relative abundance of species \(i\).
- \(N\) is the number of samples.
- \(RA_{ij}\) is the relative abundance of species \(i\) in sample \(j\).

Sort the species in descending order of their mean relative abundance and select the first 20 species.

---

## 8. Visualization of the Top 20 Species

Generate bar graphs showing the relative abundances of the 20 most abundant species.

The visualization should:

- Display species names along the x-axis.
- Display mean relative abundance on the y-axis.
- Arrange the species in descending order of mean relative abundance.
- Include a clear title and axis labels.
- Use readable species labels, rotating them if necessary to avoid overlap.

The resulting bar graph provides a visual summary of the species composition and the relative abundance of the top 20 species identified by SPINGO.

---

## 9. Expected Outputs

The SPINGO analysis should produce the following outputs:

| Output | Description |
|---|---|
| Modified Perl script | Script configured to use the local SPINGO installation and reference database |
| SPINGO classification results | Sample-specific taxonomic classification output |
| Species abundance table | Table containing species-level abundance counts across samples |
| TSS-normalized abundance table | Species abundances expressed as relative abundances |
| Top 20 species table | Species sorted by descending mean relative abundance |
| Bar graph | Visualization of the top 20 species and their mean relative abundances |

---

## 10. Conclusion

The SPINGO pipeline was configured using the local executable and the RDP 11.2 species reference database. The provided Perl script was modified to replace the original server-specific paths, and its syntax was validated using Perl's built-in syntax-checking option.

The classification results are subsequently used to calculate species-level relative abundances through total-sum scaling normalization. The top 20 species are selected according to their mean relative abundance across samples and visualized using sorted bar graphs.

