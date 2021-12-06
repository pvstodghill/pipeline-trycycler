#! /bin/bash

. doit-preamble.bash

. config14.bash

if [ -z "${GENUS}" -o "${GENUS}" = FIXME ] ; then
    echo 1>&2 config.bash: GENUS is not set.
    exit 1
fi

if [ -z "${SPECIES}" -o "${SPECIES}" = FIXME ] ; then
    echo 1>&2 config.bash: SPECIES is not set.
    exit 1
fi

# ------------------------------------------------------------------------
# Run PGAP
# ------------------------------------------------------------------------

echo 1>&2 '# Running PGAP...'

rm -rf ${PGAP_OUT}

TAXON_ID=$(esearch -db taxonomy -query "$GENUS $SPECIES" | efetch -format uid)
if [ -z "$TAXON_ID" ] ; then
    echo 1>&2 ''
    echo 1>&2 '*** TAXON_ID is empty! ***'
    exit 1
fi

./scripts/run-pgap \
    -u -f \
    -S $STRAIN${VERSION} \
    -t ${TAXON_ID} \
    -o ${PGAP_OUT} \
    -p ${PGAP_HOME} \
    ${NORMALIZED}/normalized.fasta -- ${PGAP_ARGS}

echo 1>&2 '# Finishing up...'

rm -f data/assembly.fasta

cp ${PGAP_OUT}/annot.faa data/final.faa
cp ${PGAP_OUT}/annot.fna data/final.fna
cp ${PGAP_OUT}/annot.gbk data/final.gbk
cp ${PGAP_OUT}/annot.gff data/final.gff

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

