#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Step 2. https://github.com/rrwick/Trycycler/wiki/Clustering-contigs
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

