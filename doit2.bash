#! /bin/bash

set -e
set -o pipefail

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

# ------------------------------------------------------------------------

FILTLONG=data/01_filtlong
CLUSTERS=data/04_clusters


# ------------------------------------------------------------------------
# Clean up assemblies
# ------------------------------------------------------------------------

echo 1>&2 '# Clean up assemblies'

ASSEMBLIES=data/05_assemblies
rm -rf ${ASSEMBLIES}
mkdir -p ${ASSEMBLIES}/contigs

echo 1>&2 '## creating copy'

for f in ${CLUSTERS}/cluster_*/1_contigs/*.fasta ; do
    ff=$(basename $f)
    cat $f | sed -e 's/>[A-Z]_/>/' > ${ASSEMBLIES}/contigs/$ff
done

# ------------------------------------------------------------------------

function remove_contigs {
    for name in "$@" ; do
	echo "## removing contig $name"
	(
	    set -x
	    rm -f ${ASSEMBLIES}/contigs/${name}.fasta
	)
    done
}

function remove_assemblies {
    for letter in "$@" ; do
	echo "## removing assembly $letter"
	(
	    set -x
	    rm -f ${ASSEMBLIES}/contigs/${letter}_*.fasta
	)
    done
}


. config2.bash

# ------------------------------------------------------------------------


for letter in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ; do
    (
	shopt -s nullglob
	cat /dev/null ${ASSEMBLIES}/contigs/${letter}_*.fasta \
	    > ${ASSEMBLIES}/assembly_${letter}.fna
	if [ ! -s ${ASSEMBLIES}/assembly_${letter}.fna ] ; then
	    rm -f ${ASSEMBLIES}/assembly_${letter}.fna
	fi
    )
done

# ------------------------------------------------------------------------
# Step 2. https://github.com/rrwick/Trycycler/wiki/Clustering-contigs
# ------------------------------------------------------------------------

CLUSTERS=data/06_reconciled
rm -rf ${CLUSTERS}

echo 1>&2 '# Running "trycycler cluster"...'

${HOWTO} trycycler cluster \
       --threads ${THREADS} \
       --assemblies ${ASSEMBLIES}/*.fna \
       --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
       --out_dir ${CLUSTERS}

# ------------------------------------------------------------------------
# Step 3. https://github.com/rrwick/Trycycler/wiki/Reconciling-contigs
# ------------------------------------------------------------------------

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)

    set +e

    echo 1>&2 '# Running "trycycler reconcile" on '$cluster_name'...'

    ${HOWTO} trycycler reconcile \
	     --threads ${THREADS} \
	     --reads ${FILTLONG}/filtered_nanopore.fastq.gz \
	     --cluster_dir ${cluster_dir} \
	     ${RECONCILE_ARGS}

    set -e

done

# -----

set +x

echo 1>&2 ''

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)
    if [ -e ${cluster_dir}/2_all_seqs.fasta ] ; then
	echo 1>&2 '#' $cluster_name OK
    else
	echo 1>&2 '#' $cluster_name FAILED
    fi
done

