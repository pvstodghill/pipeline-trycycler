GRAM=neg
GENUS=FIXME
SPECIES=FIXME
STRAIN=FIXME

GENOME_SIZE=5000000

NANOPORE_FQ_GZ=../000NOTES/2020-*-FIXME-demux/output/barcodeFIXME.fastq.gz

ILLUMINA_DIR=../000NOTES/2020-09-10-more-illumina-brc-downloads/
R1_FQ_GZ=$ILLUMINA_DIR/*Pag_FIXME_*_R1.fastq.gz
R2_FQ_GZ=$ILLUMINA_DIR/*Pag_FIXME_*_R2.fastq.gz

SAMPLE_DEPTH=50

NUM_CANU_ASSEMBLIES=0
NUM_FLYE_ASSEMBLIES=5
NUM_MINIPOLISH_ASSEMBLIES=5
NUM_NECAT_ASSEMBLIES=0
NUM_RAVEN_ASSEMBLIES=5
NUM_REDBEAN_ASSEMBLIES=0

#CLUSTER_ARGS="--distance 0.01" # default
#CLUSTER_ARGS="--distance 0.02" # more permissive
#CLUSTER_ARGS="--distance 0.005" # more strict

#RECONCILE_ARGS="--max_indel_size 1000" # default
#MAKE_DOTPLOTS=true # make dotplots for clusters that fail to reconcile

#SKIP_FASTP=true # Illumina reads are already trimmed

#REFSEEK=$HOME/scratch/referenceseeker

# ------------------------------------------------------------------------

if [ -e /programs/docker/bin/docker1 ] ; then
    export HOWTO_DOCKER_CMD=/programs/docker/bin/docker1
fi

# Uncomment to get packages from HOWTO
PACKAGES_FROM=howto

# uncomment to use conda
#CONDA_EXE=$(type -p conda)
#CONDA_ENV=default

# Override the default number of threads (nproc --all)
#THREADS=32
