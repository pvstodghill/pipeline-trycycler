#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Step 4. https://github.com/rrwick/Trycycler/wiki/Multiple-sequence-alignment
# ------------------------------------------------------------------------

echo 1>&2 '# Performing multiple sequence alignments'

rm -f ${RECONCILED}/cluster_*/3_msa.fasta

for cluster_dir in ${RECONCILED}/cluster_[0-9]* ; do
    cluster_name=$(basename $cluster_dir)
    echo 1>&2 '##' $cluster_name

    trycycler msa \
	     --threads ${THREADS} \
	     --cluster_dir ${cluster_dir}

done

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

