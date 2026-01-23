#!/bin/bash
#SBATCH --job-name="04_run_prokka"
#SBATCH --output="../outputs/04_run_prokka_%j.output"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=64G

# --- This step annotates your genomes using Prokka.
# --- Essentially, the program looks at your genome and assigns functions to the different predicted genes - essential for gRodon to estimate growth rate
# --- LONG STEP!

# --- Load environment ---
module purge
module load linuxbrew/colsa

# --- Configuration ---
GENOMES_DIR="../outputs/gRodon_filtered_genomes"
PROKKA_OUTPUT_DIR="../outputs/prokka_annotations"

# --- Define the Prokka function ---
run_prokka() {
    local compressed_file="$1"
    local base_name
    base_name=$(basename "${compressed_file}" .fna.gz)
    local uncompressed_file="${TMPDIR}/${base_name}.fna"

    gunzip -c "${compressed_file}" > "${uncompressed_file}"

    echo "Running Prokka for ${base_name}..."

    prokka \
        --outdir "${PROKKA_OUTPUT_DIR}/${base_name}" \
        --prefix "${base_name}" \
        --cpus 1 \
        --kingdom Bacteria \
        --quiet \
        "${uncompressed_file}"

    echo "Finished ${base_name}."

    rm "${uncompressed_file}"
}

# --- Export function for xargs subshells ---
export -f run_prokka
export PROKKA_OUTPUT_DIR

# --- Running all genomes in parallel using available CPUs ---
CORES=$SLURM_CPUS_PER_TASK
find "${GENOMES_DIR}" -name "*.fna.gz" | \
  xargs -P "${CORES}" -I {} bash -c 'run_prokka "{}"'

echo "Step 04: Prokka annotation complete."
date
