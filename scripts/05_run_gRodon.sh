#!/bin/bash
#SBATCH --job-name="05_run_gRodon"
#SBATCH --output="../outputs/05_run_gRodon_%j.out"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G

# --- This is the final step that runs gRodon on your annotated genomes.
# --- LONG STEP!

# --- Load environment ---
module purge
module load anaconda/colsa
conda activate gRodon_ernakovich

# --- Configuration ---
R_SCRIPT="05_run_gRodon.R"

echo "Starting gRodon..."
Rscript "${R_SCRIPT}"
echo "Step 05: gRodon ran successfully."
date
echo "=== Thanks for using the gRodon_ernakovich pipeline. Please cite appropriately! ==="
