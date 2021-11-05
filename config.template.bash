GRAM=neg
GENUS=FIXME
SPECIES=FIXME
STRAIN=FIXME

GENOME_SIZE=5000000

NANOPORE_FQ_GZ=../000NOTES/2020-*-FIXME-demux/output/barcodeFIXME.fastq.gz

ILLUMINA_DIR=../000NOTES/2020-09-10-more-illumina-brc-downloads/
R1_FQ_GZ=$ILLUMINA_DIR/*Pag_FIXME_*_R1.fastq.gz
R2_FQ_GZ=$ILLUMINA_DIR/*Pag_FIXME_*_R2.fastq.gz

#USE_CANU=1
USE_FLYE=1
USE_MINIPOLISH=1
USE_RAVEN=1
#USE_REDBEAN=1
#USE_NECAT=1

SAMPLE_DEPTH=50
ASMS_PER_PKG=5

# ------------------------------------------------------------------------

if [ -e /programs/docker/bin/docker1 ] ; then
    export HOWTO_DOCKER_CMD=/programs/docker/bin/docker1
fi

# if DONT_USE_STUBS is set to any non-empty string, then don't use
# ./stubs/
#DONT_USE_STUBS=yes

# uncomment to use conda
#CONDA_EXE=$(type -p conda)
#CONDA_ENV=default

# Override the default number of threads (nproc --all)
#THREADS=32
