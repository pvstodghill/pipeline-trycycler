#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Generate assemblies for Trycycler
# - Make subsample sets
# - Run individual assemblers
# (https://github.com/rrwick/Trycycler/wiki/Generating-assemblies-for-Trycycler)
# ------------------------------------------------------------------------

. ${FILTLONG}/stats.bash

mkdir -p ${ASSEMBLIES}/tmp ${ASSEMBLIES}/inputs

SEED_BASE=0
SEED_BASE_SKIP=20

function make_subsample {
    tag=$1
    j=$2

    echo "## subsampling reads"
    SEED=$[ $SEED_BASE + $j ]
    seqtk sample -s "$SEED" ${FILTLONG}/filtered_nanopore.fastq.gz "$read_count" \
    	| paste - - - - \
    	| shuf \
    	| tr '\t' '\n' \
	| gzip > ${ASSEMBLIES}/inputs/${tag}_"$j".fastq.gz

}

# ------------------------------------------------------------------------
# canu
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_CANU_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/canu_${j}.fna ] ; then
	echo "# canu $j - already exists"
	continue
    fi
    echo "# canu $j"
    make_subsample canu $j
    
    echo "## running canu"
    mkdir -p ${ASSEMBLIES}/tmp/canu_${j} 
    canu -p canu -d ${ASSEMBLIES}/tmp/canu_${j} \
		 genomeSize="$GENOME_SIZE" \
		 -corrected -trimmed \
		 -nanopore ${ASSEMBLIES}/inputs/canu_${j}.fastq.gz
    cp ${ASSEMBLIES}/tmp/canu_${j}/canu.contigs.fasta \
	   ${ASSEMBLIES}/canu_${j}.fna

done

SEED_BASE=$[ $SEED_BASE + $SEED_BASE_SKIP ]

# ------------------------------------------------------------------------
# flye
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_FLYE_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/flye_${j}.fna ] ; then
	echo "# flye $j - already exists"
	continue
    fi
    echo "# flye $j"
    make_subsample flye $j
    
    echo "## running flye"
    flye --nano-raw ${ASSEMBLIES}/inputs/flye_"$j".fastq.gz \
	 --threads "$THREADS" \
	 --out-dir ${ASSEMBLIES}/tmp/flye_${j} 
    cp ${ASSEMBLIES}/tmp/flye_${j}/assembly.fasta \
       ${ASSEMBLIES}/flye_${j}.fna

done

SEED_BASE=$[ $SEED_BASE + $SEED_BASE_SKIP ]

# ------------------------------------------------------------------------
# minipolish
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_MINIPOLISH_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/minipolish_${j}.fna ] ; then
	echo "# minipolish $j - already exists"
	continue
    fi
    echo "# minipolish $j"
    make_subsample minipolish $j
    
    echo "## running minipolish"

    # cribbed from "miniasm_and_minipolish.sh", script written by Ryan
    # Wick <rrwick@gmail.com>. Taken from
    # https://github.com/rrwick/Minipolish/blob/main/miniasm_and_minipolish.sh
    # License under GPLv3
    
    # Find read overlaps with minimap2.
    minimap2 -x ava-ont -t "$THREADS" \
	     ${ASSEMBLIES}/inputs/minipolish_${j}.fastq.gz \
	     ${ASSEMBLIES}/inputs/minipolish_${j}.fastq.gz \
	     > ${ASSEMBLIES}/tmp/minipolish_overlap_${j}.paf
    
    # Run miniasm to make an unpolished assembly.
    miniasm -f ${ASSEMBLIES}/inputs/minipolish_${j}.fastq.gz \
	    ${ASSEMBLIES}/tmp/minipolish_overlap_${j}.paf \
	    > ${ASSEMBLIES}/tmp/minipolish_unpolished_${j}.gfa
    
    # Polish the assembly with minipolish, outputting the result to stdout.
    minipolish --threads "$THREADS" \
	       ${ASSEMBLIES}/inputs/minipolish_${j}.fastq.gz \
	       ${ASSEMBLIES}/tmp/minipolish_unpolished_${j}.gfa \
	       > ${ASSEMBLIES}/tmp/minipolish_${j}.gfa

    rm ${ASSEMBLIES}/tmp/minipolish_overlap_${j}.paf \
       ${ASSEMBLIES}/tmp/minipolish_unpolished_${j}.gfa

    any2fasta ${ASSEMBLIES}/tmp/minipolish_${j}.gfa \
		      > ${ASSEMBLIES}/minipolish_${j}.fna

done

SEED_BASE=$[ $SEED_BASE + $SEED_BASE_SKIP ]

# ------------------------------------------------------------------------
# raven
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_RAVEN_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/raven_${j}.fna ] ; then
	echo "# raven $j - already exists"
	continue
    fi
    echo "# raven $j"
    make_subsample raven $j
    
    echo "## running raven"
    raven --threads "$THREADS" ${ASSEMBLIES}/inputs/raven_${j}.fastq.gz \
	  > ${ASSEMBLIES}/raven_${j}.fna
    rm raven.cereal

done

SEED_BASE=$[ $SEED_BASE + $SEED_BASE_SKIP ]

# ------------------------------------------------------------------------
# necat
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_NECAT_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/necat_${j}.fna ] ; then
	echo "# necat $j - already exists"
	continue
    fi
    echo "# necat $j"
    make_subsample necat $j
    
    echo "## running necat"
    ${PIPELINE}/scripts/run-necat -H \
			-g "$GENOME_SIZE" -t "$THREADS" \
			-w ${ASSEMBLIES}/tmp/necat_${j} \
			-o ${ASSEMBLIES}/necat_${j}.fna \
			${ASSEMBLIES}/inputs/necat_${j}.fastq.gz

done

SEED_BASE=$[ $SEED_BASE + $SEED_BASE_SKIP ]

# ------------------------------------------------------------------------
# redbean
# ------------------------------------------------------------------------

for j in $(seq 0 $[ $NUM_REDBEAN_ASSEMBLIES - 1 ]) ; do

    if [  -e ${ASSEMBLIES}/redbean_${j}.fna ] ; then
	echo "# redbean $j - already exists"
	continue
    fi
    echo "# redbean $j"
    make_subsample redbean $j
    
    echo "## running redbean"
    wtdbg2.pl -o ${ASSEMBLIES}/tmp/wtdbg2_${j} \
	      -g "$GENOME_SIZE" -t "$THREADS" -x ont \
	      ${ASSEMBLIES}/inputs/redbean_${j}.fastq.gz
    cp ${ASSEMBLIES}/tmp/wtdbg2_${j}.cns.fa \
       ${ASSEMBLIES}/redbean_${j}.fna

done

SEED_BASE=$[ $SEED_BASE + $SEED_BASE_SKIP ]

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

