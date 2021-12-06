#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Compute stats
# ------------------------------------------------------------------------

echo 1>&2 '# Compute stats...'

./scripts/compute-assembly-stats \
    -t ${THREADS} \
    -q -s -S ${STRAIN}${VERSION} \
    ${INPUTS}/raw_nanopore.fastq.gz \
    ${FILTLONG}/filtered_nanopore.fastq.gz \
    ${INPUTS}/raw_short_R1.fastq.gz \
    ${INPUTS}/raw_short_R2.fastq.gz \
    ${FASTP}/trimmed_R1.fastq.gz \
    ${FASTP}/trimmed_R2.fastq.gz \
    data/final.fna \
    data/final.gff


# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

