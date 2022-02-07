#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Run Medaka to polish the consensus assembly
# (https://github.com/rrwick/Trycycler/wiki/Polishing-after-Trycycler)
# ------------------------------------------------------------------------

rm -rf ${MEDAKA}
mkdir ${MEDAKA}

echo 1>&2 '# Polishing with long reads (Medaka)'

for cluster_dir in ${RECONCILED}/cluster_[0-9]* ; do
    cluster_name=$(basename $cluster_dir)
    echo 1>&2 '##' $(basename $cluster_dir)

    medaka_consensus \
	-i ${cluster_dir}/4_reads.fastq \
	-d ${cluster_dir}/7_final_consensus.fasta \
	-o ${MEDAKA}/${cluster_name} \
	-m r941_min_high_g360

done

cat ${MEDAKA}/cluster_*/consensus.fasta > ${MEDAKA}/polished.fasta

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

