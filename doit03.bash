#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Cluster contigs from different assemblies
# (https://github.com/rrwick/Trycycler/wiki/Clustering-contigs)
# ------------------------------------------------------------------------

echo 1>&2 '# Running "trycycler cluster"...'

rm -rf ${CLUSTERS}

trycycler cluster \
	  ${CLUSTER_ARGS} \
	  --threads ${THREADS} \
	  --assemblies ${ASSEMBLIES}/*.fna \
	  --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	  --out_dir ${CLUSTERS}

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

