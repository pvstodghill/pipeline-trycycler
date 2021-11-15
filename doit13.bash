#! /bin/bash

. doit-preamble.bash

. config13.bash

# ------------------------------------------------------------------------
# Run PGAP
# ------------------------------------------------------------------------

echo 1>&2 '# Running PGAP...'

rm -rf ${PGAP_OUT}

TAXON_ID=$(esearch -db taxonomy -query "$GENUS $SPECIES" | efetch -format uid)
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
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

