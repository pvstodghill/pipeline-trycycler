# directory into which the results are written.
#DATA=.
#DATA=data # default

STRAIN=FIXME
VERSION=

GENOME_SIZE=5000000

# ${NANOPORE_FQ_GZ} is required
NANOPORE_FQ_GZ=../000NOTES/2020-*-FIXME-demux/output/barcodeFIXME.fastq.gz

# ${Rx_FQ_GZ} are optional
ILLUMINA_DIR=../000NOTES/2020-09-10-more-illumina-brc-downloads/
R1_FQ_GZ=$ILLUMINA_DIR/*Pag_FIXME_*_R1.fastq.gz
R2_FQ_GZ=$ILLUMINA_DIR/*Pag_FIXME_*_R2.fastq.gz

SEED_BASE=0
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

FASTP_ADAPTER_ARGS= # Use auto-detection method
#FASTP_ADAPTER_ARGS=--adapter_fasta inputs/NEBnext_PE.fa
#SKIP_FASTP=true # Illumina reads are already trimmed

#REFSEEK=$HOME/scratch/referenceseeker

# ------------------------------------------------------------------------

# Uncomment to get packages from HOWTO
PACKAGES_FROM=howto

# uncomment to use conda
#PACKAGES_FROM=conda
#CONDA_EXE=$(type -p conda)
#CONDA_ENV=pipeline-trycycler

# ------------------------------------------------------------------------

# BioHPC-specific settings

if [ -e /programs/docker/bin/docker1 ] ; then
    export HOWTO_DOCKER_CMD=/programs/docker/bin/docker1
    THREADS=32
fi

