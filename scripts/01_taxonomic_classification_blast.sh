#!/bin/bash
#SBATCH --job-name="01_taxonomic_classification_blast"
#SBATCH --output="../outputs/01_taxonomic_classification_blast_%j.output"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16G

# --- This is the BLAST step. We are taking the ASV sequences and comparing them against known 16S rRNA sequences from the GTDB database.
# --- THIS IS A LONG STEP

# --- Load module ---
module purge
module load anaconda/colsa
conda activate gRodon_ernakovich

# --- Configuration ---
# --- CHANGE QUERY TO THE LOCATION OF YOUR repset.fasta FILE (LOCATED IN THE 03 FOLDER OF THE DADA2 OUTPUTS)
QUERY="/mnt/home/ernakovich/--YOUR_USERNAME--/dada2_output_run2/03_tabletax/repset.fasta"
DB="/mnt/home/ernakovich/shared/db_files/GTDB/ssu_reps_r207/ssu_reps_db"
OUT="../outputs/blast_results.txt"

# --- Running BLAST ---
blastn \
    -task megablast \
    -query "${QUERY}" \
    -db "${DB}" \
    -out "${OUT}" \
    -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore' \
    -perc_identity 95 \
    -qcov_hsp_perc 80 \
    -max_target_seqs 1 \
    -max_hsps 1 \
    -num_threads 8

# --- Details about blast optimization:
# 1. Using megablast: much more efficient and quicker.
# 2. perc_identity 95: CHANGE ME BASED ON YOUR PROJECT! 95-97 percent identity is usually good, but you can make this higher/lower depending on your project.
# 3. max_target_seqs 1: keeps only the best hit, prevents redundant hits for the same genome. You might want more hits - something to consider.
# 4. max_hsps 1: this basically tells BLAST - For any given ASV and the database sequence it matches, only show me the single best alignment region. Don't show me other weaker alignments!

echo "Step 01: Blast complete. Results saved to ${OUT}"
date
