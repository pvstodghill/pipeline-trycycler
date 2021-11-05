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
	conda activate $PACKAGES_ENV

	;;
    XhowtoX|XstubsX)
	export PATH=$(dirname ${BASH_SOURCE[0]})/stubs:"$PATH"
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

