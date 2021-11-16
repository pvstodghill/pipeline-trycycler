#! /bin/bash

. doit-preamble.bash

# ------------------------------------------------------------------------
# Step 9. https://github.com/Nextomics/NextPolish
# ------------------------------------------------------------------------

if [ -z "${R1_FQ_GZ}" ] ; then

    echo 1>&2 '# No Illumina reads to for polishing'

    cp ${MEDAKA}/polished.fasta data/assembly.fasta

else

    rm -rf ${NEXTPOLISH}
    mkdir ${NEXTPOLISH}

    echo 1>&2 '# Polishing with short-reads (Nextpolish)'

    cp ${MEDAKA}/polished.fasta ${NEXTPOLISH}/unpolished.fasta
    cp ${FASTP}/trimmed_R1.fastq.gz ${NEXTPOLISH}/trimmed_R1.fastq.gz
    cp ${FASTP}/trimmed_R2.fastq.gz ${NEXTPOLISH}/trimmed_R2.fastq.gz

    (
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

	nextPolish run.cfg

	cat tmp/03.kmer_count/*polish.ref.sh.work/polish_genome*/genome.nextpolish.part*.fasta \
	    > polished.fasta

    )

    cp ${NEXTPOLISH}/polished.fasta data/assembly.fasta

fi

# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

