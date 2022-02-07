#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Generate a consensus sequence for each cluster
# (https://github.com/rrwick/Trycycler/wiki/Generating-a-consensus)
# ------------------------------------------------------------------------

echo 1>&2 '# Generating consensus sequence'

rm -f ${RECONCILED}/cluster_[0-9]*/5_chunked_sequence.gfa
rm -f ${RECONCILED}/cluster_[0-9]*/6_initial_consensus.fasta
rm -f ${RECONCILED}/cluster_[0-9]*/7_final_consensus.fasta*

for cluster_dir in ${RECONCILED}/cluster_[0-9]* ; do
    cluster_name=$(basename $cluster_dir)
    echo 1>&2 '##' $cluster_name

    trycycler consensus \
	     --threads ${THREADS} \
	     --cluster_dir ${cluster_dir}

done

ok=1
for cluster_dir in ${RECONCILED}/cluster_[0-9]* ; do
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

cat ${RECONCILED}/cluster_*/7_final_consensus.fasta > ${RECONCILED}/consensus.fasta

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

