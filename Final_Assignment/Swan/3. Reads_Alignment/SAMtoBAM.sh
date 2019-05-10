#!/bin/bash

#SAMTOOLS sort to convert the SAM file into a BAM file to be used with StringTie
#SHOULD NOT PERFORM FILTERING ON HISAT2 OUTPUT

F=/home/stan/FinalProject/genome

array3=($(ls $F/*.sam))
    for i in ${array3[@]}; do
        samtools sort ${i} > ${i}.bam #Stringtie takes as input only sorted bam files
        echo "${i}_bam"
    done

#Get bam file statistics for percentage aligned with flagstat
# to get more detailed statistics use $ samtools stats ${i}
array4=($(ls $F/*.bam))
    for i in ${array4[@]}; do
        samtools flagstat ${i} > ${i}.bam.stats #get % mapped
    #to extract more detailed summary numbers
        samtools stats ${i} | grep ^SN | cut -f 2- > ${i}.bam.fullstat
        echo "STATS DONE" $(date)
    done
