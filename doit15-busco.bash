#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Running BUSCO...
# ------------------------------------------------------------------------

echo 1>&2 "# Running BUSCO..."

rm -rf ${BUSCO_OUT}
mkdir -p ${BUSCO_OUT}

if [ "$BUSCO_LINEAGE" ] ; then
    LINEAGE_ARG="--lineage_dataset $BUSCO_LINEAGE"
else
    LINEAGE_ARG="--auto-lineage-prok"
fi

busco \
    -q \
    -i ${DATA}/final.faa \
    -o ${BUSCO_OUT}/output \
    -m proteins \
    ${LINEAGE_ARG} \
    -c ${THREADS} \
    --download_path ${BUSCO_OUT}/downloads

# ------------------------------------------------------------------------
# Generate summary
# ------------------------------------------------------------------------

echo 1>&2 "# Generate summary"
(
    cd ${BUSCO_OUT}
    
    echo -e "Name\tdb\tC\tS\tD\tF\tM\tn"
    echo -n ${STRAIN}
    egrep '^'$'\t''C:' /dev/null output/short_summary.specific.*.txt \
	| sed -r \
	      -e 's/^output//' \
	      -e 's|/short_summary\.specific\.(.+)_odb10.output\.txt:|\t\1|' \
	      -e 's/[ \t]+$//' \
	      -e 's/C:([0-9.%]+)\[S:([0-9.%]+),D:([0-9.%]+)\],F:([0-9.%]+),M:([0-9.%]+),n:([0-9.%]+)/\1\t\2\t\3\t\4\t\5\t\6/'
) > ${BUSCO_OUT}/__report__.txt

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

