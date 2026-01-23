#!/usr/bin/env Rscript

# --- Load libraries ---
library(Biostrings)
library(gRodon)
library(dplyr)
library(tools)

# --- Define directories ---
annotation_dir <- "../outputs/prokka_annotations"
output_file <- "../outputs/gRodon_results/gRodon_estimates.csv"
dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)

# --- Get list of genome folders ---
genomes <- list.dirs(annotation_dir, recursive = FALSE, full.names = TRUE)

# --- Initialize results data frame ---
results <- data.frame(
  Genome = character(),
  CUBHE = numeric(),
  ConsistencyHE = numeric(),
  CPB = numeric(),
  FilteredSequences = integer(),
  DoublingTime_hr = numeric(),
  LowerCI = numeric(),
  UpperCI = numeric(),
  stringsAsFactors = FALSE
)

cat("=== Starting gRodon analysis ===\n")
cat(format(Sys.time()), "\n")
cat("Found", length(genomes), "genome folders in", annotation_dir, "\n\n")

for (genome_path in genomes) {
  genome_name <- basename(genome_path)
  cat("Running gRodon on:", genome_name, "\n")
  
  # --- File paths ---
  gff_file <- file.path(genome_path, paste0(genome_name, ".gff"))
  ffn_file <- file.path(genome_path, paste0(genome_name, ".ffn"))
  
  # --- Checking input files ---
  if (!file.exists(gff_file) || !file.exists(ffn_file)) {
    cat("  Missing files. Skipping.\n\n")
    next
  }
  
  # --- Load GFF and FFN ---
  gff_data <- read.delim(gff_file, header = FALSE, comment.char = "#")
  cds_annotations <- gff_data[gff_data$V3 == "CDS", ]
  cds_ids <- gsub(".*ID=([^;]+).*", "\\1", cds_annotations$V9)
  
  all_transcripts <- readDNAStringSet(ffn_file)
  cleaned_ffn_ids <- gsub(" .*", "", names(all_transcripts))
  cds_sequences <- all_transcripts[cleaned_ffn_ids %in% cds_ids]
  
  if (length(cds_sequences) == 0) {
    cat("  No CDS sequences found. Skipping.\n\n")
    next
  }
  
  cat("  Matched CDS count:", length(cds_sequences), "of", length(all_transcripts), "\n")
  
  # --- Identify ribosomal proteins ---
  highly_expressed <- grepl("ribosomal protein", names(cds_sequences), ignore.case = TRUE)
  
  # --- Run gRodon prediction ---
  pred <- tryCatch({
    predictGrowth(cds_sequences, highly_expressed)
  }, error = function(e) {
    cat("  gRodon failed:", e$message, "\n\n")
    return(NULL)
  })
  
  if (is.null(pred)) {
    cat("  No valid prediction returned. Skipping.\n\n")
    next
  }
  
  # --- Append results ---
  results <- rbind(results, data.frame(
    Genome = genome_name,
    CUBHE = pred$CUBHE,
    ConsistencyHE = pred$ConsistencyHE,
    CPB = pred$CPB,
    FilteredSequences = pred$FilteredSequences,
    DoublingTime_hr = pred$d,
    LowerCI = pred$LowerCI,
    UpperCI = pred$UpperCI,
    stringsAsFactors = FALSE
  ))
  
  cat("  Prediction complete.\n\n")
}

# --- Save final results ---
if (nrow(results) > 0) {
  write.csv(results, output_file, row.names = FALSE)
  cat("All results saved to:", output_file, "\n")
} else {
  cat("No results generated.\n")
}

cat("=== gRodon analysis complete ===\n")
cat(format(Sys.time()), "\n")

