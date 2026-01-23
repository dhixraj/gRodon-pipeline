#!/bin/bash
#SBATCH --job-name="05_extract_rp"
#SBATCH --output="../outputs/05_extract_rp_%j.output"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
 
# --- Configuration ---
PROKKA_OUTPUT_DIR="../outputs/prokka_annotations"
FINAL_RP_LIST="../outputs/highly_expressed_genes.txt"

# --- Main ---
echo "Searching for GFF files in ${PROKKA_OUTPUT_DIR}..."

# The grep command is now a simpler, case-insensitive search for "ribosomal protein"
find "${PROKKA_OUTPUT_DIR}" -name "*.gff" -print0 | \
  xargs -0 grep -i "ribosomal protein" | \
  grep -oP 'ID=[^;]+' | \
  sed 's/ID=//' > "${FINAL_RP_LIST}"

RP_COUNT=$(wc -l < "${FINAL_RP_LIST}")
echo "Done. Found ${RP_COUNT} ribosomal protein genes."
echo "Final list saved to: ${FINAL_RP_LIST}"
