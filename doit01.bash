#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Step 1. https://github.com/rrwick/Trycycler/wiki/Generating-assemblies-for-Trycycler
# ------------------------------------------------------------------------

# "Some light read QC"

rm -rf ${FILTLONG}
mkdir -p ${FILTLONG}

echo 1>&2 '# Running filtlong...'
filtlong --min_length 1000 --keep_percent 95 \
       ${INPUTS}/raw_nanopore.fastq.gz \
    | gzip > ${FILTLONG}/filtered_nanopore.fastq.gz

mean_length=$(seqtk comp ${FILTLONG}/filtered_nanopore.fastq.gz | awk '{count++; bases += $2} END{print bases/count}')
read_count=$(echo $SAMPLE_DEPTH"*"$GENOME_SIZE"/"$mean_length | bc)

(
    echo mean_length=$mean_length
    echo read_count=$read_count
) | tee ${FILTLONG}/stats.bash

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'
