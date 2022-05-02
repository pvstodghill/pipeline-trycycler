#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Run unicycler (for a second opinion on the assembly)
# ------------------------------------------------------------------------

echo 1>&2 '# Running unicycler'

rm -rf ${UNICYCLER}
mkdir ${UNICYCLER}

unicycler -t ${THREADS} \
	  -1 ${FASTP}/trimmed_R1.fastq.gz \
	  -2 ${FASTP}/trimmed_R2.fastq.gz \
	  -l ${FILTLONG}/filtered_nanopore.fastq.gz \
	  -o ${UNICYCLER}

# ------------------------------------------------------------------------

echo 1>&2 '# Running DNADiff'

mkdir ${UNICYCLER}/dnadiff
cp ${DATA}/assembly.fasta ${UNICYCLER}/dnadiff/trycycler.fasta
cp ${UNICYCLER}/assembly.fasta ${UNICYCLER}/dnadiff/unicycler.fasta
cd ${UNICYCLER}/dnadiff
dnadiff trycycler.fasta unicycler.fasta
echo ''
cat out.report


# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

