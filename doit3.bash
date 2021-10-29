#! /bin/bash

set -e
set -o pipefail

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

# ------------------------------------------------------------------------

INPUTS=data/00_inputs
FILTLONG=data/01_filtlong

CLUSTERS=data/06_reconciled

if [ ! -d ${CLUSTERS} ] ; then
    echo 1>&2 '# Noticing that doit2.bash was not run...'
    CLUSTERS=data/04_clusters
fi


# ------------------------------------------------------------------------
# Step 4. https://github.com/rrwick/Trycycler/wiki/Multiple-sequence-alignment
# ------------------------------------------------------------------------

echo 1>&2 '# Performing multiple sequence alignments'

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)
    echo 1>&2 '##' $cluster_name

    ${HOWTO} trycycler msa \
	     --threads ${THREADS} \
	     --cluster_dir ${cluster_dir}

done

# ------------------------------------------------------------------------
# Step 5. https://github.com/rrwick/Trycycler/wiki/Partitioning-reads
# ------------------------------------------------------------------------

echo 1>&2 '# Partitioning reads onto clusters'

${HOWTO} trycycler partition \
	 --threads ${THREADS} \
	 --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	 --cluster_dirs ${CLUSTERS}/cluster_*

# ------------------------------------------------------------------------
# Step 6. https://github.com/rrwick/Trycycler/wiki/Generating-a-consensus
# ------------------------------------------------------------------------

echo 1>&2 '# Generating consensus sequence'

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)
    echo 1>&2 '##' $cluster_name

    ${HOWTO} trycycler consensus \
	     --threads ${THREADS} \
	     --cluster_dir ${cluster_dir}

done

ok=1
for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)

    if [ -e ${cluster_dir}/7_final_consensus.fasta ] ; then
	echo 1>&2 '## 'cluster_name': OK'
    else
	echo 1>&2 '## 'cluster_name': FAILED!'
	ok=
    fi

done

if [ ! "$ok" ] ; then
    exit 1
fi

cat ${CLUSTERS}/cluster_*/7_final_consensus.fasta > ${CLUSTERS}/consensus.fasta

# ------------------------------------------------------------------------
# Step 7. https://github.com/rrwick/Trycycler/wiki/Polishing-after-Trycycler
# ------------------------------------------------------------------------

MEDAKA=data/07_medaka
rm -rf ${MEDAKA}
mkdir ${MEDAKA}

echo 1>&2 '# Polishing with long reads (Medaka)'

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)
    echo 1>&2 '##' $(basename $cluster_dir)

    ${HOWTO} medaka_consensus \
	     -i ${cluster_dir}/4_reads.fastq \
	     -d ${cluster_dir}/7_final_consensus.fasta \
	     -o ${MEDAKA}/${cluster_name} \
	     -m r941_min_high_g360

done

cat ${MEDAKA}/cluster_*/consensus.fasta > ${MEDAKA}/polished.fasta

# ------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------

echo 1>&2 '# Done!'

