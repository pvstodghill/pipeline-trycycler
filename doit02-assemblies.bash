#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Generate assemblies for Trycycler
# - Make subsample sets
# - Run individual assemblers
# (https://github.com/rrwick/Trycycler/wiki/Generating-assemblies-for-Trycycler)
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# Subsample reads
# ------------------------------------------------------------------------

mkdir -p ${ASSEMBLIES}/tmp ${ASSEMBLIES}/inputs

NUM_SUBSAMPLES=0
NUM_SUBSAMPLES=$[ ${NUM_SUBSAMPLES} + ${NUM_CANU_ASSEMBLIES} ]
NUM_SUBSAMPLES=$[ ${NUM_SUBSAMPLES} + ${NUM_FLYE_ASSEMBLIES} ]
NUM_SUBSAMPLES=$[ ${NUM_SUBSAMPLES} + ${NUM_MINIPOLISH_ASSEMBLIES} ]
NUM_SUBSAMPLES=$[ ${NUM_SUBSAMPLES} + ${NUM_NECAT_ASSEMBLIES} ]
NUM_SUBSAMPLES=$[ ${NUM_SUBSAMPLES} + ${NUM_RAVEN_ASSEMBLIES} ]
NUM_SUBSAMPLES=$[ ${NUM_SUBSAMPLES} + ${NUM_REDBEAN_ASSEMBLIES} ]

trycycler subsample \
	  --genome_size ${GENOME_SIZE} \
	  --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	  --out_dir ${ASSEMBLIES}/inputs \
	  --count ${NUM_SUBSAMPLES} \
	  --threads ${THREADS}

CUR_SUBSAMPLE=0

# ------------------------------------------------------------------------
# canu
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_CANU_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/canu_${j}.fna ] ; then
	echo "# canu $j - already exists"
	continue
    fi

    CUR_SUBSAMPLE=$[ ${CUR_SUBSAMPLE} + 1 ]
    CUR_FASTQ=$(printf "${ASSEMBLIES}/inputs/sample_%02d.fastq" ${CUR_SUBSAMPLE})
    echo "# canu $j: ${CUR_FASTQ}"
    
    echo "## running canu"
    mkdir -p ${ASSEMBLIES}/tmp/canu_${j} 
    canu -p canu -d ${ASSEMBLIES}/tmp/canu_${j} \
		 genomeSize="$GENOME_SIZE" \
		 -corrected -trimmed \
		 -nanopore ${CUR_FASTQ}
    cp ${ASSEMBLIES}/tmp/canu_${j}/canu.contigs.fasta \
	   ${ASSEMBLIES}/canu_${j}.fna

done

# ------------------------------------------------------------------------
# flye
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_FLYE_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/flye_${j}.fna ] ; then
	echo "# flye $j - already exists"
	continue
    fi

    CUR_SUBSAMPLE=$[ ${CUR_SUBSAMPLE} + 1 ]
    CUR_FASTQ=$(printf "${ASSEMBLIES}/inputs/sample_%02d.fastq" ${CUR_SUBSAMPLE})
    echo "# flye $j: ${CUR_FASTQ}"
    
    echo "## running flye"
    flye --nano-raw ${CUR_FASTQ} \
	 --threads "$THREADS" \
	 --out-dir ${ASSEMBLIES}/tmp/flye_${j} 
    cp ${ASSEMBLIES}/tmp/flye_${j}/assembly.fasta \
       ${ASSEMBLIES}/flye_${j}.fna

done

# ------------------------------------------------------------------------
# minipolish
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_MINIPOLISH_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/minipolish_${j}.fna ] ; then
	echo "# minipolish $j - already exists"
	continue
    fi

    CUR_SUBSAMPLE=$[ ${CUR_SUBSAMPLE} + 1 ]
    CUR_FASTQ=$(printf "${ASSEMBLIES}/inputs/sample_%02d.fastq" ${CUR_SUBSAMPLE})
    echo "# minipolish $j: ${CUR_FASTQ}"
    
    echo "## running minipolish"

    # cribbed from "miniasm_and_minipolish.sh", script written by Ryan
    # Wick <rrwick@gmail.com>. Taken from
    # https://github.com/rrwick/Minipolish/blob/main/miniasm_and_minipolish.sh
    # License under GPLv3
    
    # Find read overlaps with minimap2.
    minimap2 -x ava-ont -t "$THREADS" \
	     ${CUR_FASTQ} \
	     ${CUR_FASTQ} \
	     > ${ASSEMBLIES}/tmp/minipolish_overlap_${j}.paf
    
    # Run miniasm to make an unpolished assembly.
    miniasm -f ${CUR_FASTQ} \
	    ${ASSEMBLIES}/tmp/minipolish_overlap_${j}.paf \
	    > ${ASSEMBLIES}/tmp/minipolish_unpolished_${j}.gfa
    
    # Polish the assembly with minipolish, outputting the result to stdout.
    minipolish --threads "$THREADS" \
	       ${CUR_FASTQ} \
	       ${ASSEMBLIES}/tmp/minipolish_unpolished_${j}.gfa \
	       > ${ASSEMBLIES}/tmp/minipolish_${j}.gfa

    rm ${ASSEMBLIES}/tmp/minipolish_overlap_${j}.paf \
       ${ASSEMBLIES}/tmp/minipolish_unpolished_${j}.gfa

    any2fasta ${ASSEMBLIES}/tmp/minipolish_${j}.gfa \
		      > ${ASSEMBLIES}/minipolish_${j}.fna

done

# ------------------------------------------------------------------------
# raven
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_RAVEN_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/raven_${j}.fna ] ; then
	echo "# raven $j - already exists"
	continue
    fi

    CUR_SUBSAMPLE=$[ ${CUR_SUBSAMPLE} + 1 ]
    CUR_FASTQ=$(printf "${ASSEMBLIES}/inputs/sample_%02d.fastq" ${CUR_SUBSAMPLE})
    echo "# raven $j: ${CUR_FASTQ}"
    
    echo "## running raven"
    raven --threads "$THREADS" ${CUR_FASTQ} \
	  --graphical-fragment-assembly ${ASSEMBLIES}/raven_${j}.gfa \
	  > ${ASSEMBLIES}/raven_${j}.fna
    rm raven.cereal

done

# ------------------------------------------------------------------------
# necat
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_NECAT_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/necat_${j}.fna ] ; then
	echo "# necat $j - already exists"
	continue
    fi

    CUR_SUBSAMPLE=$[ ${CUR_SUBSAMPLE} + 1 ]
    CUR_FASTQ=$(printf "${ASSEMBLIES}/inputs/sample_%02d.fastq" ${CUR_SUBSAMPLE})
    echo "# necat $j: ${CUR_FASTQ}"
    
    echo "## running necat"
    ${PIPELINE}/scripts/run-necat -H \
			-g "$GENOME_SIZE" -t "$THREADS" \
			-w ${ASSEMBLIES}/tmp/necat_${j} \
			-o ${ASSEMBLIES}/necat_${j}.fna \
			${CUR_FASTQ}

done

# ------------------------------------------------------------------------
# redbean
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_REDBEAN_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/redbean_${j}.fna ] ; then
	echo "# redbean $j - already exists"
	continue
    fi

    CUR_SUBSAMPLE=$[ ${CUR_SUBSAMPLE} + 1 ]
    CUR_FASTQ=$(printf "${ASSEMBLIES}/inputs/sample_%02d.fastq" ${CUR_SUBSAMPLE})
    echo "# redbean $j: ${CUR_FASTQ}"
    
    echo "## running redbean"
    wtdbg2.pl -o ${ASSEMBLIES}/tmp/wtdbg2_${j} \
	      -g "$GENOME_SIZE" -t "$THREADS" -x ont \
	      ${CUR_FASTQ}
    cp ${ASSEMBLIES}/tmp/wtdbg2_${j}.cns.fa \
       ${ASSEMBLIES}/redbean_${j}.fna

done

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

