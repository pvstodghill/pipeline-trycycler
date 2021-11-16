#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------

if [ ! -f data/assembly.fasta ] ; then
    echo 1>&2 'data/assembly.fasta is missing.'
    exit 1
fi

# ------------------------------------------------------------------------
# "Normalize" the genome.
# ------------------------------------------------------------------------

echo 1>&2 '# "Normalizing" the genome...'

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
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

