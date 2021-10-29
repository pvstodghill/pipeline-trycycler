#! /bin/bash

set -e
set -o pipefail

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

. config4.bash

# ------------------------------------------------------------------------

if [ ! -f data/assembly.fasta ] ; then
    echo 1>&2 'data/assembly.fasta is missing.'
    exit 1
fi

# ------------------------------------------------------------------------

echo 1>&2 '# "Normalizing" the genome...'


NORMALIZED=data/10_normalized
rm -rf ${NORMALIZED}
mkdir -p ${NORMALIZED}

cat data/assembly.fasta \
    | ./scripts/dephix \
	  > ${NORMALIZED}/unnormalized.fasta

./scripts/normalize-assembly \
    -d ${NORMALIZED}/tmp \
    -f inputs/starts.faa \
    ${NORMALIZED}/unnormalized.fasta ${STRAIN}_ \
    > ${NORMALIZED}/normalized.fasta

# ------------------------------------------------------------------------

echo 1>&2 '# Running PGAP...'

PGAP_OUT=data/11_pgap
rm -rf ${PGAP_OUT}

TAXON_ID=$(${HOWTO} esearch -db taxonomy -query "$GENUS $SPECIES" | ${HOWTO} efetch -format uid)
./scripts/run-pgap \
     -u -f \
     -S $STRAIN \
     -t ${TAXON_ID} \
     -o ${PGAP_OUT} \
     -p ${PGAP_HOME} \
     ${NORMALIZED}/normalized.fasta -- ${PGAP_ARGS}

rm -f data/assembly.fasta

cp ${PGAP_OUT}/annot.faa data/final.faa
cp ${PGAP_OUT}/annot.fna data/final.fna
cp ${PGAP_OUT}/annot.gbk data/final.gbk
cp ${PGAP_OUT}/annot.gff data/final.gff


# ------------------------------------------------------------------------

echo 1>&2 '# Compute stats...'

./scripts/compute-assembly-stats \
    -f packages.yaml -t ${THREADS} \
    -q -s -S ${STRAIN} \
    data/00_inputs/raw_nanopore.fastq.gz \
    data/01_filtlong/filtered_nanopore.fastq.gz \
    data/00_inputs/raw_short_R1.fastq.gz \
    data/00_inputs/raw_short_R2.fastq.gz \
    data/08_fastp/trimmed_R1.fastq.gz \
    data/08_fastp/trimmed_R2.fastq.gz \
    data/final.fna \
    data/final.gff


# ------------------------------------------------------------------------

echo 1>&2 '# Done.'

