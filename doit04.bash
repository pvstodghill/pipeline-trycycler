#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Reconcile the contigs in each clustern
# (https://github.com/rrwick/Trycycler/wiki/Reconciling-contigs)
# ------------------------------------------------------------------------

echo 1>&2 '# Running "trycycler reconcile"...'

# --- initializing ${RECONCILED} from ${CLUSTERS}

if [ -e ${RECONCILED} ] ; then
    echo 1>&2 "## ${RECONCILED} exists. reusing..."
else
    echo 1>&2 '## creating fresh copy of clusters'
    rm -rf ${RECONCILED}
    cp --archive ${CLUSTERS} ${RECONCILED}
    rm -f ${RECONCILED}/contigs.*
fi

# --- making user directed edits to clusters, contigs, etc.

function remove_clusters {
    for index in "$@" ; do
	if [ -e ${RECONCILED}/cluster_00${index} ] ; then
	    path=${RECONCILED}/cluster_00${index}
	elif [ -e ${RECONCILED}/cluster_0${index} ] ; then
	    path=${RECONCILED}/cluster_0${index}
	elif [ -e ${RECONCILED}/cluster_${index} ] ; then
	    path=${RECONCILED}/cluster_${index}
	fi
	if [ "$path" ] ; then
	    echo "## removing cluster $index"
	    (
		set -x
		rm -rf $path
	    )
	fi
    done
}

function remove_contigs {
    (
	shopt -s nullglob
	for name in "$@" ; do
	    echo "## removing contig $name"
	    paths="$(echo ${RECONCILED}/cluster_*/1_contigs/$name.fasta)"
	    for path in $paths ; do
		(
		    set -x
		    rm -f $path
		)
		cluster_xxx=$(dirname $(dirname $path))
		rm -f ${cluster_xxx}/2_all_seqs.fasta
	    done
	done
    )
}

function remove_assemblies {
    (
	shopt -s nullglob
	for letter in "$@" ; do
	    echo "## removing assembly $letter"
	    paths="$(echo ${RECONCILED}/cluster_*/1_contigs/${letter}_*.fasta)"
	    for path in $paths ; do
		(
		    set -x
		    rm -f $path
		)
		cluster_xxx=$(dirname $(dirname $path))
		rm -f ${cluster_xxx}/2_all_seqs.fasta
	    done
	done
    )
}


echo 1>&2 '## editing clusters'

. config04.bash

# ------------------------------------------------------------------------

for cluster_dir in ${RECONCILED}/cluster_[0-9]* ; do
    cluster_name=$(basename $cluster_dir)
    cluster_num=$(echo $cluster_name | sed -e 's/cluster_//')
    RECONCILE_ARGS_XXX=RECONCILE_ARGS_${cluster_num}

    if [ -e "${cluster_dir}/2_all_seqs.fasta" ] ; then
	echo 1>&2 '## skipping  '$cluster_name'...'
	continue
    fi

    set +e

    echo 1>&2 '## running "trycycler reconcile" on '$cluster_name'...'

    trycycler reconcile \
	     --threads ${THREADS} \
	     --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	     --cluster_dir ${cluster_dir} \
	     ${RECONCILE_ARGS} ${!RECONCILE_ARGS_XXX}

    set -e

    if [ ! -e "${cluster_dir}/2_all_seqs.fasta" -a "$MAKE_DOTPLOTS" ] ; then
	echo 1>&2 '# Running "trycycler dotplot" on '$cluster_name'...'
	trycycler dotplot -c ${cluster_dir}
    fi


done

# ------------------------------------------------------------------------

echo 1>&2 ''

OK=1

for cluster_dir in ${RECONCILED}/cluster_[0-9]* ; do
    cluster_name=$(basename $cluster_dir)
    if [ -e ${cluster_dir}/2_all_seqs.fasta ] ; then
	echo 1>&2 '#' $cluster_name OK
    else
	echo 1>&2 '#' $cluster_name FAILED
	OK=
    fi
done

if [ -z "$OK" ] ; then
    exit 1
fi

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

