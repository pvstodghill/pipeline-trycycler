#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------

if [ ! -f ${DATA}/assembly.fasta ] ; then
    echo 1>&2 '${DATA}/assembly.fasta is missing.'
    exit 1
fi

# ------------------------------------------------------------------------
# "Normalize" the genome.
# ------------------------------------------------------------------------

echo 1>&2 '# "Normalizing" the genome...'

rm -rf ${NORMALIZED}
mkdir -p ${NORMALIZED}

cat ${DATA}/assembly.fasta \
    | ${PIPELINE}/scripts/dephix \
	  > ${NORMALIZED}/unnormalized.fasta

${PIPELINE}/scripts/normalize-assembly \
    -d ${NORMALIZED}/tmp \
    -f ${PIPELINE}/inputs/starts.faa \
    ${NORMALIZED}/unnormalized.fasta ${STRAIN}${VERSION}_ \
    > ${NORMALIZED}/normalized.fasta

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

