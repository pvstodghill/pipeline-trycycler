#! /bin/bash

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

# ------------------------------------------------------------------------

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

INPUTS=data/00_inputs
FILTLONG=data/01_filtlong
ASSEMBLIES=data/02_assemblies
CLUSTERS=data/03_clusters
RECONCILED=data/04_clusters
MEDAKA=data/08_medaka
FASTP=data/09_fastp 
NEXTPOLISH=data/10_nextpolish
UNICYCLER=data/12_unicycler
NORMALIZED=data/13_normalized
PGAP_OUT=data/14_pgap

