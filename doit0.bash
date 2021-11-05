#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Step 0. Set up
# ------------------------------------------------------------------------

if [ -d data ] ; then
    echo 1>&2 "data/ already exists. cannot continue."
    exit 1
fi

echo 1>&2 '# Initializing data/...'
mkdir -p data/tmp

INPUTS=data/00_inputs
mkdir -p ${INPUTS}

echo 1>&2 '# Making copies of raw reads...'

cp ${NANOPORE_FQ_GZ} ${INPUTS}/raw_nanopore.fastq.gz
if [ "${R1_FQ_GZ}" ] ; then
    cp ${R1_FQ_GZ} ${INPUTS}/raw_short_R1.fastq.gz
    cp ${R2_FQ_GZ} ${INPUTS}/raw_short_R2.fastq.gz
fi

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

