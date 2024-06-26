#! /bin/bash

echo 1>&2 this currently fails. python conflicts b/w busco, nextpolish
exit 1

set -e

NAME=pipeline-trycycler
if [ "${TARGET_CONDA_ENV}" ] ; then
    NAME="${TARGET_CONDA_ENV}"
fi

CONDA_PREFIX=$(dirname $(dirname $(type -p conda)))
. "${CONDA_PREFIX}/etc/profile.d/conda.sh"

PACKAGES=
#PACKAGES+=" pip"

PACKAGES+=" any2fasta"
PACKAGES+=" blast"
PACKAGES+=" bowtie2"
PACKAGES+=" busco"
PACKAGES+=" canu"
PACKAGES+=" emboss"
PACKAGES+=" entrez-direct"
PACKAGES+=" fastp"
PACKAGES+=" filtlong"
PACKAGES+=" flye"
PACKAGES+=" medaka"
PACKAGES+=" minipolish"
PACKAGES+=" mummer"
PACKAGES+=" necat"
PACKAGES+=" nextpolish"
PACKAGES+=" raven-assembler"
PACKAGES+=" referenceseeker"
PACKAGES+=" samtools"
PACKAGES+=" seqtk"
PACKAGES+=" trycycler"
PACKAGES+=" unicycler"

#PACKAGES+=" wtdbg2" - not available

if [ "$(type -p mamba)" ] ; then
    _conda="mamba --no-banner"
else
    _conda=conda
fi

function __ {
    echo + "$@"
    eval "$@"
}

if [ "$1" = -f ] ; then
    __ conda env remove -y --name ${NAME}
fi

_install=update
if [ ! -d ${CONDA_PREFIX}/envs/${NAME} ] ; then
    __ conda create -y --name ${NAME}
    _install=install
fi
__ conda activate ${NAME}

__ $_conda $_install -y ${PACKAGES}

# __ pip $_install FIXME
