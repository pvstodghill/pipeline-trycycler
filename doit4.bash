#! /bin/bash

set -e
set -o pipefail

HOWTO="./scripts/howto -q -T data/tmp -f packages.yaml"
THREADS=$(nproc --all)

export LC_ALL=C

# ------------------------------------------------------------------------

. config.bash

# ------------------------------------------------------------------------

INPUTS=data/00_inputs
MEDAKA=data/07_medaka

CLUSTERS=data/06_reconciled

if [ ! -d ${MEDAKA} ] ; then
    echo 1>&2 '# doit3.bash was not run!'
    exit 1
fi

# ------------------------------------------------------------------------
# Step 8. https://github.com/OpenGene/fastp
# ------------------------------------------------------------------------


if [ "${R1_FQ_GZ}" ] ; then

    FASTP=data/08_fastp
    rm -rf ${FASTP}
    mkdir ${FASTP}

    echo 1>&2 '# Clean-up Illumina reads'

    ${HOWTO} fastp \
	     --thread ${THREADS} \
	     --adapter_fasta inputs/NEBnext_PE.fa \
	     --json ${FASTP}/fastp.json \
	     --html ${FASTP}/fastp.html \
	     --in1 ${INPUTS}/raw_short_R1.fastq.gz \
	     --in2 ${INPUTS}/raw_short_R2.fastq.gz  \
	     --out1 ${FASTP}/trimmed_R1.fastq.gz \
	     --out2 ${FASTP}/trimmed_R2.fastq.gz \
	     --unpaired1 ${FASTP}/u.fastq.gz \
	     --unpaired2 ${FASTP}/u.fastq.gz

    # echo 1>&2 '# Skipping Illumina clean-up'

    # cp inputs/*_1_trimmed.fastq.gz ${FASTP}/trimmed_R1.fastq.gz
    # cp inputs/*_2_trimmed.fastq.gz ${FASTP}/trimmed_R2.fastq.gz
    # cat inputs/*_U[12]_trimmed.fastq.gz > ${FASTP}/u.fastq.gz

fi

# ------------------------------------------------------------------------
# Step 9. https://github.com/Nextomics/NextPolish
# ------------------------------------------------------------------------

if [ "${R1_FQ_GZ}" ] ; then

    NEXTPOLISH=data/09_nextpolish

    rm -rf ${NEXTPOLISH}
    mkdir ${NEXTPOLISH}

    echo 1>&2 '# Polishing with short-reads (Nextpolish)'

    cp ${MEDAKA}/polished.fasta ${NEXTPOLISH}/unpolished.fasta
    cp ${FASTP}/trimmed_R1.fastq.gz ${NEXTPOLISH}/trimmed_R1.fastq.gz
    cp ${FASTP}/trimmed_R2.fastq.gz ${NEXTPOLISH}/trimmed_R2.fastq.gz

    cp packages.yaml ${NEXTPOLISH} # <- lame!

    cd ${NEXTPOLISH}

    cat <<EOF > sgs.fofn
trimmed_R1.fastq.gz
trimmed_R2.fastq.gz
EOF

    cat <<EOF  > run.cfg
task = best
genome = unpolished.fasta
sgs_fofn = sgs.fofn
workdir = tmp
EOF

    ${HOWTO} nextPolish run.cfg

    cat tmp/03.kmer_count/*polish.ref.sh.work/polish_genome*/genome.nextpolish.part*.fasta \
	> polished.fasta

    cd ../..

fi

# ------------------------------------------------------------------------
# Finish up
# ------------------------------------------------------------------------

echo 1>&2 '# Consolidating results'

for cluster_dir in ${CLUSTERS}/cluster_00* ; do
    cluster_name=$(basename $cluster_dir)
    cp ${cluster_dir}/5_chunked_sequence.gfa data/${cluster_name}.trycycler.gfa
done

if [ "${R1_FQ_GZ}" ] ; then
    cp ${NEXTPOLISH}/polished.fasta data/assembly.fasta
else
    cp ${MEDAKA}/polished.fasta data/assembly.fasta
fi
    
# ------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------

echo 1>&2 '# Done!'

