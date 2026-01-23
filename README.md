This pipeline estimates maximal bacterial growth rates of ASVs from 16S rRNA amplicon data using gRodon by retrieving species-specific metagenomes from GTDB.

# GENERAL OVERVIEW OF PIPELINE
1. Taxonomic Mapping (BLAST): ASV sequences are aligned against the GTDB Small Subunit (SSU) representative database to find the closest matching reference genome.

2. Genome Retrieval: The full genome assemblies for the matched GTDB accessions are retrieved/filtered from the GTDB database.

3. Functional Annotation (Prokka): Genomes undergo rapid annotation to identify coding sequences (CDS) and highly expressed genes (ribosomal proteins), which are required inputs for growth rate prediction.

4. Growth Rate Prediction (gRodon): The gRodon package calculates the maximal growth rate through codon usage bias.

# Prelimemary Checklist - Before you begin
## There are a few essentials you need before you can run this pipeline:
1. Ensure that you have processed your data through the dada2pipeline (https://github.com/ErnakovichLab/dada2_ernakovichlab). This will produce a repset.fasta file (in the 03 folder).
2. Ensure that you know your desired BLAST settings as this can vary per project. I will talk about this more during the BLAST step.
3. Ensure that you know how Prokka works (https://github.com/tseemann/prokka).
4. And finally, familiarize yourself with how gRodon works (https://github.com/jlw-ecoevo/gRodon2).

### NOTE: There is a newer program developed by JL called Phydon. Look into it.

# Downloading the pipeline
Once you have logged in, you can download a copy of the tutorial into your directory on the server. To retrieve the folder with this tutorial from github directly to the server, type the following into your terminal.

```bash
wget https://github.com/dhixraj/gRodon-pipeline/
```
This pipeline is developed with settings that you can change based on your requirements. The ```scripts``` folder has slurm/R scripts that are ready to be submitted (which small changes to file paths, of course). 

# 00. Setting up directories
Organization. Super important. Go ahead and
```bash
sbatch 00_setup_directories.sh
```
for me. This will set up all the directories needed to keep your output files nice and organized.

Ensure that you have an outputs directory created outside your scripts directory.

# 01. Taxonomic Classification
In this step, we are comparing (BLASTing) each of your ASV sequences against the known representative 16s rRNA sequences in the GTDB database.

Optimization settings:
1. Using megablast: much more efficient and quicker.
2. perc_identity 95: CHANGE ME BASED ON YOUR PROJECT! 95-97 percent identity is usually good, but you can make this higher/lower depending on your project.
3. max_target_seqs 1: keeps only the best hit, prevents redundant hits for the same genome. You might want more hits - something to consider.
4. max_hsps 1: this basically tells BLAST - For any given ASV and the database sequence it matches, only show me the single best alignment region. Don't show me other weaker alignments!

### NOTE: This is a <ins>LONG STEP</ins>!

Ready to use blast? Go ahead and
```bash
sbatch 01_taxonomic_classification_blast.sh
```
for me. 

This gives us the output file ```blast_results.txt```

# 02. 
