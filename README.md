# General overview of pipeline
This pipeline estimates maximal bacterial growth rates of ASVs from 16S rRNA amplicon data using gRodon by retrieving species-specific metagenomes from GTDB. The whole process involves the following steps:
1. Taxonomic Mapping (BLAST): ASV sequences are aligned against the GTDB Small Subunit (SSU) representative database to find the closest matching reference genome.
2. Genome Retrieval: The full genome assemblies for the matched GTDB accessions are retrieved/filtered from the GTDB database.
3. Functional Annotation (Prokka): Genomes undergo rapid annotation to identify coding sequences (CDS) and highly expressed genes (ribosomal proteins), which are required inputs for growth rate prediction.
4. Growth Rate Prediction (gRodon): The gRodon package calculates the maximal growth rate through codon usage bias.

# Prelimemary Checklist - Before you begin
#### There are a few essentials you need before you can run this pipeline:
1. Ensure that you have processed your data through the [dada2pipeline](https://github.com/ErnakovichLab/dada2_ernakovichlab). This will produce a repset.fasta file (in the 03_tabletax folder).
2. Ensure that you know your desired BLAST settings as this can vary per project. I will talk about this more during the BLAST step.
3. Familiarize yourself with how [Prokka works](https://github.com/tseemann/prokka).
4. And finally, familiarize yourself with how [gRodon works](https://github.com/jlw-ecoevo/gRodon2).

| <span>                                                                                                                                                                                                                                                       |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **NOTE:** There is a newer program developed by JL called Phydon. Look into it. |
| <span>     

# Downloading the pipeline
Once you have logged in, you can download a copy of the tutorial into your directory on the server. To retrieve the folder with this tutorial from github directly to the server, type the following into your terminal.

```bash
git clone https://github.com/dhixraj/gRodon-pipeline.git
cd gRodon-pipeline
```
This pipeline is developed with settings that you can change based on your requirements. The ```scripts``` folder has slurm/R scripts that are ready to be submitted (which small changes to file paths, of course).

```bash
cd scripts
```
This is where all of the code lives. Submit jobs from this directory.

# 00. Setting up directories
Organization. Super important. Go ahead and
```bash
sbatch 00_setup_directories.sh
```
for me. This will set up all the directories needed to keep your output files nice and organized.

Check that you have a new outputs directory created outside your scripts directory.

# 01. Taxonomic Classification
In this step, we are comparing (BLASTing) each of your ASV sequences against the known representative 16s rRNA sequences in the GTDB database.

What is BLAST? 
BLAST (Basic Local Alignment Search Tool) is a widely used algorithm that compares your biological sequences (like DNA or protein) against a reference database to find the closest matches, helping you identify taxonomy or function of sequences.

Optimization settings:
1. ```megablast```: A quicker and more efficient version of BLAST.
2. ```perc_identity 95```: CHANGE ME BASED ON YOUR PROJECT! 95-97 percent identity is usually good, but you can make this higher/lower depending on your project.
3. ```max_target_seqs 1```: keeps only the best hit, prevents redundant hits for the same genome. You might want more hits - something to consider.
4. ```max_hsps 1```: this basically tells BLAST - For any given ASV and the database sequence it matches, only show me the single best alignment region. Don't show me other weaker alignments!

| <span>                                                                                                                                                                                                                                                       |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **NOTE:** This is a <ins>LONG STEP</ins>! |
| <span>     

Ready to use blast? Go ahead and
```bash
sbatch 01_taxonomic_classification_blast.sh
```
for me. 

This gives us the output file ```blast_results.txt```
#### Understanding these results:
Here's an example output:
```
ASV_52732 GB_GCA_000756795.1~CCSI01000004.1 97.088 373 67 9 2 368 473 840 1.29e-63 246
```
Each line in the file represents a hit, which is a match between one of your sequences and a sequence in the GTDB database.
1. ```ASV_52732```: The Query Sequence ID. This is one of your unique sequences from the repset.fasta file.
2. ```GB_GCA_```: The Subject Sequence ID. This is the unique identifier for the matching sequence from the GTDB database (our GTDB accession number)
3. ```97.088```: Percent Identity. The percentage of identical bases between your query sequence and the subject sequence.
4. ```373```: Alignment Length. The total number of base pairs that were aligned between the two sequences.
5. ```67```: Mismatches. The number of bases that were different.
6. ```9```: Gap Openings. The number of gaps introduced in the alignment.
7. ```2```: Query Start. The starting position of the match on your query sequence.
8. ```368```: Query End. The ending position of the match on your query sequence.
9. ```473```: Subject Start. The starting position of the match on the GTDB sequence.
10. ```840```: Subject End. The ending position of the match on the GTDB sequence.
11. ```1.29e-63```: E-value. A statistical value that indicates the probability of getting a match this good by random chance (a lower E-value is better).
12. ```246```: Bit Score. The raw score of the alignment, normalized for database size. A higher bit score is better.

# 02. Extracting GTDB accession numbers from BLAST results
In this step, we are extracting all of the unique GTDB accession numbers from our BLAST results. This is a pretty quick step!

Go ahead and
```
sbatch 02_parse_blast_results.sh
```
Our output file is a ```gtdb_accessions.txt``` file with our accession numbers, and a ```blast_parsed_results.tsv``` file that is human-readable with details about your ASVs, its corresponding accession number (genome ID), and all other necessary information.

# 03. Filtering the required genomes from the GTDB database
In this step, we are reading the full list of GTDB accession numbers and copying the corresponding full genome files from the large database into a new directory. This will also be a quick step. 
```
sbatch 03_filter_genomes.sh
```
The corresponding genomes will be copied into the ```gRodon_filtered_genomes``` directory.

# 04. Genome annotation with Prokka
The goal of this step is to use ```Prokka``` to perform rapid gene prediction and functional annotation on our filtered genomes. Initially, this step was split into two, where ```Prodigal``` was used to predict open reading frames (ORFs), and the ribosomal protein identification was done by BLASTing against the GTDB protein database. This was extremely long and time-consuming. ```Prokka``` will directly identify coding sequences (ORFs) and assign them biological functions, preparing the data for gRodon.

Some context – An open reading frame (ORF) is a part of the DNA (or RNA) sequence that can be translated into amino acids (which make up proteins). It is a stretch of codons that begins with a start codon (ATG in DNA, translated into AUG in mRNA), and ends with a stop codon (TAA/TAG/TGA, translated into UAA/UAG/UGA in mRNA). Prodigal is used to find and predict ORFs from our sequences. Prokka can find the ORFs and assign gene functions together.

| <span>                                                                                                                                                                                                                                                       |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **NOTE:** This is a <ins>LONG STEP</ins>! |
| <span>     

You know what to do
```
sbatch scripts/04_run_prokka.sh
```
The annotated files are in the ```prokka_annotations``` folder.

# 05. Running gRodon
You have made it to the last step of this pipeline with (hopefully) no issues! We will finally be running gRodon on the genomes to predict their growth rates.
This step has a slurm script AND an R script (since gRodon is an R package). 

| <span>                                                                                                                                                                                                                                                       |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **NOTE:** Depending on the number of samples and species diversity, this step can take anywhere from 5-6 hours to a whole day. If it takes more than 2 days, there’s something wrong. |
| <span>     

Finally,
```
sbatch 05_run_gRodon.sh
```

The final output file is ```gRodon_estimates.csv```
#### Understanding these results:
Here's an example output:
```
"Genome",           "CUBHE",  "ConsistencyHE",  "CPB",     "FilteredSequences",  "DoublingTime_hr",  "LowerCI",         "UpperCI"
"GCA_5.1_genomic",  0.563,    0.498,             -0.234,   298,                  7.71304835739319,   5.61197311521796,  10.7607167798235
```

1. ```Genome```: The GTDB accession ID of the ASV
2. ```CUBHE``` (Codon Usage Bias of Highly Expressed genes): A score of how optimized the genes are. Higher values = predicted faster growth.
3. ```ConsistencyHE```: Measures if the ribosomal proteins have similar codon usage. Higher is better; low values mean the prediction might be unreliable.
4. ```CPB``` (Codon Pair Bias): A secondary metric measuring bias in pairs of codons across the whole genome. Used to refine the growth prediction.
5. ```FilteredSequences```: The number of genes thrown out of the analysis because they were too short or had errors.
6. ```DoublingTime_hr```: The estimated minimal doubling time in hours. Lower number = faster growth.
7. ```LowerCI / UpperCI```: The 95% confidence interval (range of error). The true doubling time likely falls between these two numbers.

Congrats! You have successfully predicted the maximal growth rates of ASVs in your samples!

# Acknowledgements and Citations
Please make sure to cite all the appropriate scientists for their awesome work on this pipeline! 
1. [Hannah Holland-Moritz](https://github.com/hhollandmoritz) - For guidance and support in every step of the process. 
2. [JL Weissman] - For developing gRodon. [PAPER]
3. [Torsten Seemann] - For developing Prokka. [PAPER]
4. Nathan D Blais - For mentoring me and pushing me to do more.
