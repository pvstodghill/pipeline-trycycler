#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Parition the long reads across the clusters
# (https://github.com/rrwick/Trycycler/wiki/Partitioning-reads)
# ------------------------------------------------------------------------

echo 1>&2 '# Partitioning reads onto clusters'

rm -f ${RECONCILED}/cluster_[0-9]*/4_reads.fastq

trycycler partition \
	 --threads ${THREADS} \
	 --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	 --cluster_dirs ${RECONCILED}/cluster_*

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

