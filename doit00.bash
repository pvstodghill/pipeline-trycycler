#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Set up
# ------------------------------------------------------------------------

if [ -d data ] ; then
    echo 1>&2 "data/ already exists. cannot continue."
    exit 1
fi

echo 1>&2 '# Initializing data/...'
mkdir -p data/tmp

mkdir -p ${INPUTS}

echo 1>&2 '# Making copies of raw reads...'

cat ${NANOPORE_FQ_GZ} > ${INPUTS}/raw_nanopore.fastq.gz
if [ "${R1_FQ_GZ}" ] ; then
    cat ${R1_FQ_GZ} > ${INPUTS}/raw_short_R1.fastq.gz
fi
if [ "${R2_FQ_GZ}" ] ; then
    cat ${R2_FQ_GZ} > ${INPUTS}/raw_short_R2.fastq.gz
fi

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

