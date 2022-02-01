#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Compute stats
# ------------------------------------------------------------------------

echo 1>&2 '# Compute stats...'

ARGS="-q -s"

if [ "$R2_FQ_GZ" ] ; then

    ./scripts/compute-assembly-stats \
	-t ${THREADS} \
	${ARGS} -S ${STRAIN}${VERSION} \
	${INPUTS}/raw_nanopore.fastq.gz \
	${FILTLONG}/filtered_nanopore.fastq.gz \
	${INPUTS}/raw_short_R1.fastq.gz \
	${INPUTS}/raw_short_R2.fastq.gz \
	${FASTP}/trimmed_R1.fastq.gz \
	${FASTP}/trimmed_R2.fastq.gz \
	data/final.fna \
	data/final.gff

else

    ./scripts/compute-assembly-stats \
	-t ${THREADS} \
	${ARGS} -S ${STRAIN}${VERSION} \
	${INPUTS}/raw_nanopore.fastq.gz \
	${FILTLONG}/filtered_nanopore.fastq.gz \
	${INPUTS}/raw_short_R1.fastq.gz \
	"" \
	${FASTP}/trimmed_R1.fastq.gz \
	"" \
	data/final.fna \
	data/final.gff

fi

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

