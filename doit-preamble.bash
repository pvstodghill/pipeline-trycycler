#! /bin/bash

THREADS=$(nproc --all)

export LC_ALL=C

PIPELINE=$(dirname ${BASH_SOURCE[0]})
DATA=data

# ------------------------------------------------------------------------

. config.bash

# ------------------------------------------------------------------------

export HOWTO_TMPDIR=$(realpath ${DATA})/tmp

if [ "$PACKAGES_FROM" = conda ] ; then
    if [ -z "$CONDA_EXE" ] ; then
	CONDA_EXE=$(type -p conda)
    fi
fi

# In order to help test portability, I eliminate all of my
# personalizations from the PATH, etc.
if [ "$PVSE" ] ; then
    export PATH=/usr/local/bin:/usr/bin:/bin
    export PERL5LIB=
    export PERL_LOCAL_LIB_ROOT=
    export PERL_MB_OPT=
    export PERL_MM_OPT=
    export PYTHONPATH=
fi

case X"$PACKAGES_FROM"X in
    XcondaX)
	CONDA_PREFIX=$(dirname $(dirname $CONDA_EXE))
	. "${CONDA_PREFIX}/etc/profile.d/conda.sh"
	conda activate $CONDA_ENV

	;;
    XhowtoX|XstubsX)
	export PATH=$(realpath $(dirname ${BASH_SOURCE[0]}))/stubs:"$PATH"
	;;
    XnativeX)
	: nothing
	;;
    XX)
	echo 1>&2 "\$PACKAGES_FROM is not set"
	exit 1
	;;
    X*X)
	echo 1>&2 "\$PACKAGES_FROM is recognized: $PACKAGES_FROM"
	exit 1
	;;
    *)
	echo 1>&2 "Cannot happen"
	exit 1
esac

# ------------------------------------------------------------------------

if [ -z "$PARALLEL_CMD" ] ; then
    PARALLEL_CMD="$(type -p parallel)"
fi

function run_commands {
    if [ "$PARALLEL_CMD" ] ; then
	eval $PARALLEL_CMD -j ${THREADS} -kv
    else
	bash -x
    fi
}

# ------------------------------------------------------------------------

set -e
set -o pipefail

# ------------------------------------------------------------------------

INPUTS=${DATA}/00_inputs
FILTLONG=${DATA}/01_filtlong
ASSEMBLIES=${DATA}/02_assemblies
CLUSTERS=${DATA}/03_clusters
RECONCILED=${DATA}/04_reconciled
MEDAKA=${DATA}/08_medaka
FASTP=${DATA}/09_fastp 
NEXTPOLISH=${DATA}/10_nextpolish
UNICYCLER=${DATA}/12_unicycler
NORMALIZED=${DATA}/13_normalized
PGAP_OUT=${DATA}/14_pgap

