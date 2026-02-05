#!/bin/bash
#SBATCH --job-name="03_filter_genomes"
#SBATCH --output="../outputs/03_filter_genomes_%j.output"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

# --- This step reads the gtdb_accessions.txt and copies the corresponding genomes from the full database into a new directory.
# --- QUICK STEP, UNDER 5 MINUTES

# --- Load environment ---
module purge
module load anaconda/colsa
conda activate base

# --- Configuration ---
GTDB_ACCESSIONS_LIST="../outputs/gtdb_accessions.txt"
GTDB_REPS_DIR="../gtdb_files/gtdb_genomes/gtdb_genomes_reps_r207"
FILTERED_GENOMES_DIR="../outputs/gRodon_filtered_genomes"

# --- Preparing cleaned accession list ---
sed 's/^RS_//; s/^GB_//' "${GTDB_ACCESSIONS_LIST}" > "${FILTERED_GENOMES_DIR}/temp_accessions.txt"

# --- Filtering and copying genomes ---
find "${GTDB_REPS_DIR}" -type f -name "*.fna.gz" | \
  grep -Ff "${FILTERED_GENOMES_DIR}/temp_accessions.txt" | \
  xargs -P 8 -I {} cp {} "${FILTERED_GENOMES_DIR}/"

# --- Clean up ---
rm "${FILTERED_GENOMES_DIR}/temp_accessions.txt"

# --- Summary ---
COPIED=$(ls "${FILTERED_GENOMES_DIR}"/*.fna.gz 2>/dev/null | wc -l)

echo "Step 03: Genome filtering complete."
echo "Copied ${COPIED} genomes into ${FILTERED_GENOMES_DIR}."
date
