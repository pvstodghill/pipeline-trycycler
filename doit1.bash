#! /bin/bash

set -e
set -o pipefail

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

INPUTS=data/00_inputs

# ------------------------------------------------------------------------
# Step 1. https://github.com/rrwick/Trycycler/wiki/Generating-assemblies-for-Trycycler
# ------------------------------------------------------------------------

# "Some light read QC"

FILTLONG=data/01_filtlong
mkdir -p ${FILTLONG}

echo 1>&2 '# Running filtlong...'
${HOWTO} filtlong --min_length 1000 --keep_percent 95 \
       ${INPUTS}/raw_nanopore.fastq.gz \
    | gzip > ${FILTLONG}/filtered_nanopore.fastq.gz

# Random subsamples

SUBSAMPLES=data/02_subsamples
mkdir -p ${SUBSAMPLES}

mean_length=$(${HOWTO} seqtk comp ${FILTLONG}/filtered_nanopore.fastq.gz | awk '{count++; bases += $2} END{print bases/count}')
read_count=$(echo $SAMPLE_DEPTH"*"$GENOME_SIZE"/"$mean_length | bc)

echo mean_length=$mean_length
echo read_count=$read_count

# fixme: this is an ugly hack
function sample_letter {
    case "$1" in
	0) echo A ;;
	1) echo B ;;
	2) echo C ;;
	3) echo D ;;
	4) echo E ;;
	5) echo F ;;
	6) echo G ;;
	7) echo H ;;
	8) echo I ;;
	9) echo J ;;
	10) echo K ;;
	11) echo L ;;
	12) echo M ;;
	13) echo N ;;
	14) echo O ;;
	15) echo P ;;
	16) echo Q ;;
	17) echo R ;;
	18) echo S ;;
	19) echo T ;;
	20) echo U ;;
	21) echo V ;;
	22) echo W ;;
	23) echo X ;;
	24) echo Y ;;
	25) echo Z ;;
	*)
	    echo 1>&2 "sample_letter: $1"
	    exit 1
    esac
}

NUM_ASSEMBLERS=0
if [ "$USE_FLYE" ] ; then
    NUM_ASSEMBLERS=$[ $NUM_ASSEMBLERS + 1 ]
fi
if [ "$USE_MINIPOLISH" ] ; then
    NUM_ASSEMBLERS=$[ $NUM_ASSEMBLERS + 1 ]
fi
if [ "$USE_RAVEN" ] ; then
    NUM_ASSEMBLERS=$[ $NUM_ASSEMBLERS + 1 ]
fi
if [ "$USE_REDBEAN" ] ; then
    NUM_ASSEMBLERS=$[ $NUM_ASSEMBLERS + 1 ]
fi
if [ "$USE_NECAT" ] ; then
    NUM_ASSEMBLERS=$[ $NUM_ASSEMBLERS + 1 ]
fi

for i in $(seq 0 $[$NUM_ASSEMBLERS * $ASMS_PER_PKG - 1]) ; do
    l=$(sample_letter $i)
    echo "# Generating sample $l..."
    ${HOWTO} seqtk sample -s "$l" ${FILTLONG}/filtered_nanopore.fastq.gz "$read_count" \
    	| paste - - - - \
    	| shuf \
    	| tr '\t' '\n' > ${SUBSAMPLES}/sample_"$l".fastq
done

pigz ${SUBSAMPLES}/sample_*.fastq

# Assemblies

ASSEMBLIES=data/03_assemblies
mkdir -p ${ASSEMBLIES}/tmp

i=0

# flye
if [ "$USE_FLYE" ] ; then
    for j in $(seq 1 $ASMS_PER_PKG) ; do
	l=$(sample_letter $i)
	echo "# Running flye $j -> $l..."

	${HOWTO} flye --nano-raw ${SUBSAMPLES}/sample_${l}.fastq.gz \
    		 --threads "$THREADS" \
    		 --out-dir ${ASSEMBLIES}/tmp/flye_${l} 
	cp ${ASSEMBLIES}/tmp/flye_${l}/assembly.fasta \
	   ${ASSEMBLIES}/assembly_${l}.fna

	i=$[ $i + 1 ]
    done
fi

# miniasm/minipolish
if [ "$USE_MINIPOLISH" ] ; then
    for j in $(seq 1 $ASMS_PER_PKG) ; do
	l=$(sample_letter $i)
	echo "# Running minipolish $j -> $l..."


	${HOWTO} miniasm_and_minipolish.sh \
    		 ${SUBSAMPLES}/sample_${l}.fastq.gz "$THREADS" \
    		 > ${ASSEMBLIES}/tmp/minipolish_${l}.gfa
	${HOWTO} any2fasta ${ASSEMBLIES}/tmp/minipolish_${l}.gfa \
    		 > ${ASSEMBLIES}/assembly_${l}.fna

	i=$[ $i + 1 ]
    done
fi

# raven
if [ "$USE_RAVEN" ] ; then
    for j in $(seq 1 $ASMS_PER_PKG) ; do
	l=$(sample_letter $i)
	echo "# Running raven $j -> $l..."


	${HOWTO} raven --threads "$THREADS" ${SUBSAMPLES}/sample_${l}.fastq.gz \
    		 > ${ASSEMBLIES}/assembly_${l}.fna
	rm raven.cereal

	i=$[ $i + 1 ]
    done
fi

# redbean (wtdbg2)
if [ "$USE_REDBEAN" ] ; then
    for j in $(seq 1 $ASMS_PER_PKG) ; do
	l=$(sample_letter $i)
	echo "# Running wtdbg2 $j -> $l..."

	${HOWTO} wtdbg2.pl -o ${ASSEMBLIES}/tmp/wtdbg2_${l} \
    		 -g "$GENOME_SIZE" -t "$THREADS" -x ont \
    		 ${SUBSAMPLES}/sample_${l}.fastq.gz
	cp ${ASSEMBLIES}/tmp/wtdbg2_${l}.cns.fa \
	   ${ASSEMBLIES}/assembly_${l}.fna

	i=$[ $i + 1 ]
    done
fi

# necat
if [ "$USE_NECAT" ] ; then
    for j in $(seq 1 $ASMS_PER_PKG) ; do
	l=$(sample_letter $i)
	echo "# Running necat $j -> $l..."

	./scripts/run-necat -f packages.yaml \
    			    -g "$GENOME_SIZE" -t "$THREADS" \
    			    -w ${ASSEMBLIES}/tmp/necat_${l} \
    			    -o ${ASSEMBLIES}/assembly_${l}.fna \
    			    ${SUBSAMPLES}/sample_${l}.fastq.gz

	i=$[ $i + 1 ]
    done
fi

# ------------------------------------------------------------------------
# Step 2. https://github.com/rrwick/Trycycler/wiki/Clustering-contigs
# ------------------------------------------------------------------------

CLUSTERS=data/04_clusters

echo 1>&2 '# Running "trycycler cluster"...'

${HOWTO} trycycler cluster \
       --threads ${THREADS} \
       --assemblies ${ASSEMBLIES}/*.fna \
       --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
       --out_dir ${CLUSTERS}

# ------------------------------------------------------------------------
# Step 3. https://github.com/rrwick/Trycycler/wiki/Reconciling-contigs
# ------------------------------------------------------------------------

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)

    set +e

    echo 1>&2 '# Running "trycycler reconcile" on '$cluster_name'...'

    ${HOWTO} trycycler reconcile \
	     --threads ${THREADS} \
	     --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	     --cluster_dir ${cluster_dir}

    set -e

done

# -----

set +x

echo 1>&2 ''

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)
    if [ -e ${cluster_dir}/2_all_seqs.fasta ] ; then
	echo 1>&2 '#' $cluster_name OK
    else
	echo 1>&2 '#' $cluster_name FAILED
    fi
done

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

