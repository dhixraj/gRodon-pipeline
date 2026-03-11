#!/bin/bash
#SBATCH --job-name="02_parse_blast_results"
#SBATCH --output="../outputs/02_parse_blast_results_%j.output"
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G # This step probably doesn't take 2G of memory - hhm. In fact it probably doesn't need to be run on the job scheduler at all unless you have tones of files. 

# --- This step is extracting the unique GTDB accession numbers from blast_results.txt and saving them to a file. These accession numbers corrrespond to genomes in the database. # I like how you define what these functions all do! -hhm
# --- QUICK STEP, UNDER 5 MINUTES.

# --- Load environment ---
module purge
module load anaconda/colsa
conda activate gRodon_ernakovich

# --- Configuration ---
BLAST_RESULTS="../outputs/blast_results.txt"
OUT_PARSED="../outputs/blast_parsed_results.tsv"
GTDB_ACCESSIONS_LIST="../outputs/gtdb_accessions.txt"

# --- Checking if blast_results.txt file exists ---
if [[ ! -f "${BLAST_RESULTS}" ]]; then
  echo "Error: BLAST results file not found"
  exit 1
fi

# --- Parsing BLAST results into a readable summary file ---
# Columns in outfmt:      qseqid      sseqid                  pident  length  mismatch gapopen qstart qend sstart send evalue bitscore
# Here's an example output: ASV1      GCF_000277795.1_genomic 99.5    253     0        0       1      253  1      253  1e-120 520

echo -e "QueryID\tGenomeID\tPercentIdentity\tAlignmentLength\tEvalue\tBitScore" > "${OUT_PARSED}"
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$11"\t"$12}' "${BLAST_RESULTS}" >> "${OUT_PARSED}"

# --- Extracting unique genome accession numbers for downstream filtering ---
# Removes any prefixes like "RS_" or "GB_" and keeps only unique IDs. # what do the RS_ and GB_ prefixes mean? Aren't they part of the accession numbers? To make this comment more informative to the user, you could say something like "remove the prefixes because they are not in the genome file names.", or something similar -hhm. 
awk 'NR>1 {print $2}' "${OUT_PARSED}" | sed 's/^RS_//; s/^GB_//' | sort -u > "${GTDB_ACCESSIONS_LIST}"

# --- Summary ---
TOTAL_HITS=$(($(wc -l < "${OUT_PARSED}") - 1))
TOTAL_ACCESSIONS=$(wc -l < "${GTDB_ACCESSIONS_LIST}")

echo "Step 02: BLAST parsing complete."
echo "Parsed ${TOTAL_HITS} BLAST hits into: ${OUT_PARSED}"
echo "Found ${TOTAL_ACCESSIONS} unique GTDB genome accessions."
date
