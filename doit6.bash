#! /bin/bash

set -e
set -o pipefail

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

# ------------------------------------------------------------------------

echo 1>&2 '# Running unicycler...'

FILTLONG=data/01_filtlong
FASTP=data/08_fastp


UNICYCLER=data/12_unicycler
rm -rf ${UNICYCLER}
mkdir ${UNICYCLER}

${HOWTO} unicycler -t ${THREADS} \
	 -1 ${FASTP}/trimmed_R1.fastq.gz \
	 -2 ${FASTP}/trimmed_R2.fastq.gz \
	 -l ${FILTLONG}/filtered_nanopore.fastq.gz \
	 -o ${UNICYCLER}

# ------------------------------------------------------------------------

echo 1>&2 '# Done.'

