#!/bin/bash
#SBATCH --job-name="00_setup_directories"
#SBATCH --output="00_setup_directories_%j.output"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

# --- Input/output directories
OUTPUT_DIR="../outputs"
PROKKA_DIR="${OUTPUT_DIR}/prokka_annotations"
FILTERED_GENOMES_DIR="${OUTPUT_DIR}/gRodon_filtered_genomes"
GRODON_RESULTS_DIR="${OUTPUT_DIR}/gRodon_results"

# --- Creating required directories
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${PROKKA_DIR}"
mkdir -p "${FILTERED_GENOMES_DIR}"
mkdir -p "${GRODON_RESULTS_DIR}"

echo "Created the following directories:"
echo "  - ${OUTPUT_DIR}"
echo "  - ${PROKKA_DIR}"
echo "  - ${FILTERED_GENOMES_DIR}"
echo "  - ${GRODON_RESULTS_DIR}"

