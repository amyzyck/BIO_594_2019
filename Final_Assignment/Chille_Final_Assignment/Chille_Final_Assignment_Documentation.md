## Final Assignment Project Documentation
Population Structure and Gene Flow in *Acropora cervicornis*  
Author: E. Chille  

### Step 1: Prepare Project Workspace
Create project directory
```
mkdir finalproject
cd finalproject
mkdir data
```
Create conda environment
```
conda create -n finalproject
conda activate finalproject
```

### Step 2: Download Data Using SRA-Toolkit
Download and Unpack SRA-Toolkit
```
cd ../../RAID_STORAGE2/echille
mkdir finalproject
wget "ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz"

tar -xzf sratoolkit.current-centos_linux64.tar.gz
```
Configure SRA-Toolkit
```
cd sratoolkit.2.9.6-centos_linux64/bin/
./vdb-config -i
```
Download data as fastq file  
*Followed [documentation](https://edwards.sdsu.edu/research/fastq-dump/) from Edwards Lab, San Diego State University.*

```
cat SraAccListp | parallel "./fastq-dump --outdir fastq --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip {}"

 # Run in background
 ^Z
 BG
 Disown -a
```
 - **parallel:** Runs all fastq dumps in parallel
 - **fastq-dump:** Downloads SRA data as a fastq file
 - **outdir fastq:** Puts output files into fastq directory
 - **gzip:** Compresses output files
 - **skip-technical:** Dumps only biological reads.
 - **readids:** Appends the ID# with .1 and .2 for split files. This is what programs for paired-end reads expects for input,
 - **read-filter pass:** Filters reads that do not pass filtering
 - **dumpbase:** Formats sequence using base space.
 - **split-3:** Separates the read into left and right ends. If there is a left end without a matching right end, or a right end without a matching left end, they will be put in a single file.
 - **clip:** Applies left and right clips to remove tags.
 
Make symbolic link to echille final project directory
```
cd ../../echille/finalproject/data
ln -s /RAID_STORAGE2/echille/finalproject
```

### Step 3: Initial Raw Data Assesment and Characterization  
*No checksum was provided for these samples on NCBI*

#### Check Read Counts
```
zcat SRR7235989_pass_1.fastq.gz | echo $((`wc -l`/4))
```
|Index|SRR Number|Expected Number of Reads|Reads Written Pass 1|Reads Written Pass 2|
|:-----:|:----------:|:----------:|:----------:|:--------:|
|1|SRR7235989|11,738,621|11738621|11738621|
|2|SRR7235990|10,218,844|10218844|10218844|
|3|SRR7235991|14,623,446|14623446|14623446|
|4|SRR7235992|11,529,163|11529163|11529163|
|5|SRR7235993|15,710,422|15710422|15710422|
|6|SRR7235994|13,661,163|13661163|13661163|
|7|SRR7235996|13,428,706|13428706|13428706|
|8|SRR7235998|16,010,284|16010284|16010284|
|9|SRR7235999|17,830,992|17830992|17830992|
|10|SRR7236021|14,846,260|14846260|14846260|
|11|SRR7236022|14,794,553|14794553|14794553|
|12|SRR7236028|17,339,044|17339044|17339044|
|13|SRR7236029|17,877,353|17877353|17877353|
|14|SRR7236030|13,739,115|13739115|13739115|
|15|SRR7236031|11,541,826|11541826|11541826|
|16|SRR7236032|12,659,512|12659512|12659512|
|17|SRR7236033|16,820,439|16820439|16820439|
|18|SRR7236034|11,054,898|11054898|11054898|
|19|SRR7236036|16,589,862|16589862|16589862|
|20|SRR7236037|14,925,154|14925154|14925154|


#### Check Read Quality Using FastQC and MultiQC

Install and Run FastQC
```
conda install -c bioconda fastqc
fastqc ../*fastq.gz .
```

Install and Run MultiQC  
*MultiQC parses bioinformatic analyses from FastQC and combines them into a single HTML report*
```
conda install -c bioconda multiqc
multiqc .
```
Save HTML file on local directory
```
scp -r -P xxxx echille@kitt.uri.edu:/home/echille/finalproject/data/finalproject/sratoolkit.2.9.6-centos_linux64/bin/fastq/fastqc ~/Documents/repos/BIO594_Puritz/Final_Assignment/Chille_Final_Assignment/MultiQC_results
```
##### MultiQC Results:  
![fastqc_sequence_counts](https://raw.githubusercontent.com/jpuritz/BIO_594_2019/master/Final_Assignment/Chille_Final_Assignment/MultiQC_results/fastqc_sequence_counts_plot.png)  
![fastqc_mean_quality_scores](https://raw.githubusercontent.com/jpuritz/BIO_594_2019/master/Final_Assignment/Chille_Final_Assignment/MultiQC_results/fastqc_per_base_sequence_quality_plot.png)  
![fastqc_per_sequence_quality_scores](https://raw.githubusercontent.com/jpuritz/BIO_594_2019/master/Final_Assignment/Chille_Final_Assignment/MultiQC_results/fastqc_per_sequence_quality_scores_plot.png)  
![fastqc_per_sequence_gc_content](https://raw.githubusercontent.com/jpuritz/BIO_594_2019/master/Final_Assignment/Chille_Final_Assignment/MultiQC_results/fastqc_per_sequence_gc_content_plot.png)  


### Step 4: Quality Trimming and Adaptor Removal Using Trimmomatic  

Download [Trimmomatic](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf)
```
curl -L -O http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
unzip Trimmomatic-0.39.zip
rm Trimmomatic-0.39.zip
```
Link fastq files to Timmomatic directory
```
cd Trimmomatic-0.39
ln -s ../*fastq.gz .
```
Run Trimmomatic with loop
```
for i in *pass_1.fastq.gz; do
    rsam=${i%pass*}
    java -jar trimmomatic-0.39.jar PE -phred33 $i ${rsam}pass_2.fastq.gz ${i}_paired_qtrim.fq.gz ${i}_unpaired_qtrim.fq.gz ${rsam}pass_2_paired_qtrim.fq.gz ${rsam}pass_2_unpaired_qtrim.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:5 TRAILING:3 SLIDINGWINDOW:4:25 MINLEN:50
    done
```
Trimmomatic started with errors:
```
TrimmomaticPE: Started with arguments:
 -phred33 SRR7235989_pass_1.fastq.gz SRR7235989_pass_2.fastq.gz SRR7235989_pass_1.fastq.gz_paired_qtrim.fq.gz SRR7235989_pass_1.fastq.gz_unpaired_qtrim.fq.gz SRR7235989_pass_2_paired_qtrim.fq.gz SRR7235989_pass_2_unpaired_qtrim.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:5 TRAILING:3 SLIDINGWINDOW:4:25 MINLEN:50
java.io.FileNotFoundException: /RAID_STORAGE2/echille/finalproject/sratoolkit.2.9.6-centos_linux64/bin/fastq/trimmed_reads/Trimmomatic-0.39/TruSeq3-PE.fa (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
	at java.io.FileInputStream.open(FileInputStream.java:195)
	at java.io.FileInputStream.<init>(FileInputStream.java:138)
	at org.usadellab.trimmomatic.fasta.FastaParser.parse(FastaParser.java:54)
	at org.usadellab.trimmomatic.trim.IlluminaClippingTrimmer.loadSequences(IlluminaClippingTrimmer.java:110)
	at org.usadellab.trimmomatic.trim.IlluminaClippingTrimmer.makeIlluminaClippingTrimmer(IlluminaClippingTrimmer.java:71)
	at org.usadellab.trimmomatic.trim.TrimmerFactory.makeTrimmer(TrimmerFactory.java:32)
	at org.usadellab.trimmomatic.Trimmomatic.createTrimmers(Trimmomatic.java:59)
	at org.usadellab.trimmomatic.TrimmomaticPE.run(TrimmomaticPE.java:552)
	at org.usadellab.trimmomatic.Trimmomatic.main(Trimmomatic.java:80)
 ```
Quality-Check Trimmed Reads
```
mkdir qtrim
mv *qtrim.fastq.gz ./qtrim/
cd qtrim
fastqc *qtrim.fastq.gz .
multiqc
```
Save HTML file on local directory
```
scp -r -P xxxx echille@kitt.uri.edu:/home/echille/finalproject/data/finalproject/sratoolkit.2.9.6-centos_linux64/bin/fastq/trimmed_reads/Trimmomatic-0.39/qtrim ~/Documents/repos/BIO594_Puritz/Final_Assignment/Chille_Final_Assignment/MultiQC_results
```
##### MultiQC Results for Trimmed Files:  

![image](http://mdp.tylingsoft.com/icon.png)
![image](http://mdp.tylingsoft.com/icon.png)
![image](http://mdp.tylingsoft.com/icon.png)
![image](http://mdp.tylingsoft.com/icon.png)

#### Step 6: Map Reads to Reference Genome  
Transfer reference [genome](https://www.ncbi.nlm.nih.gov/nuccore/1004128514?report=fasta) from local directory.
```
cd Downloads
scp -r -P xxxx sequence.fasta echille@kitt.uri.edu:/RAID_STORAGE2/echille/finalproject/sratoolkit.2.9.6-centos_linux64/bin/reference
```
Rename sequence.fasta to reference.fasta
```
mv sequence.fasta ./reference.fasta
```
Make directory for mapping
```
mkdir mapping
cd mapping
```
Link trimmed fastq files and reference.fasta file to mapping directory
```
ln -s ../data/finalproject/sratoolkit.2.9.6-centos_linux64/bin/reference/reference.fasta .
ln -s ../data/finalproject/sratoolkit.2.9.6-centos_linux64/bin/fastq/trimmed_reads/Trimmomatic-0.39/qtrim/*paired_qtrim.fq.gz .
```
Set up an index for the reference genome 
```
samtools faidx reference.fasta
bwa index reference.fasta &> index.log
```
Create and execute a bash [script](https://github.com/jpuritz/BIO_594_2019/blob/master/Final_Assignment/Chille_Final_Assignment/Scripts/bwa.sh) to run bwa
```
nano bwa.sh

#!/bin/bash
F=/home/echille/finalproject/mapping/
array1=($(ls *qtrim.fq.gz | sed 's/qtrim.fq.gz//g'))

#bwa index reference.fasta
echo "done index $(date)"

for i in ${array1[@]}; do
  bwa mem $F/reference.fasta ${i}.pass_1* ${i}.pass_2* -t 8 -a -M -B 3 -O 5 -R -T 20 -A "@RG\tID:${i}\tSM:${i}\tPL:Illumina" 2> bwa.${i}.log | samtools view -@4 -q 1 -SbT $F/reference.fasta - > ${i}.bam
  																						    
        	else
  echo "done ${i}"
done

array2=($(ls *.bam | sed 's/.bam//g'))

#now sort the bam files with samtools sort
for i in ${array2[@]}; do
  samtools sort -@8 ${i}.bam -o ${i}.bam && samtools index ${i}.bam
done

bwa.sh
```



#### Step 7: Call SNPs
Create popmap file for SNP filtering  
*File available [here](https://github.com/jpuritz/BIO_594_2019/blob/master/Final_Assignment/Chille_Final_Assignment/popmap)*



