import os

configfile: "config.template.yaml" # fixme!

DATA=config['data'] if 'data' in config else "data"
PIPELINE=os.path.dirname(workflow.snakefile)

GENOME_SIZE = config['genome_size'] if 'genome_size' in config else '5m'

GZIP="pigz"

NUM_ASMS_FLYE=( config['num_asms_flye'] if 'num_asms_flye' in config else 0 )
NUM_ASMS_MINIPOLISH=( config['num_asms_minipolish'] if 'num_asms_minipolish' in config else 0 )
NUM_ASMS_RAVEN=( config['num_asms_raven'] if 'num_asms_raven' in config else 0 )

NUM_ASMS = NUM_ASMS_FLYE + NUM_ASMS_MINIPOLISH + NUM_ASMS_RAVEN

ASMS_INDICES_FLYE = list(map((lambda j: "%02d" % (j)),range(1,NUM_ASMS_FLYE+1)))
ASMS_INDICES_MINIPOLISH = list(map((lambda j: "%02d" % (j)),range(NUM_ASMS_FLYE+1,NUM_ASMS_FLYE+NUM_ASMS_MINIPOLISH+1)))
ASMS_INDICES_RAVEN = list(map((lambda j: "%02d" % (j)),range(NUM_ASMS_FLYE+NUM_ASMS_MINIPOLISH+1,NUM_ASMS_FLYE+NUM_ASMS_MINIPOLISH+NUM_ASMS_RAVEN+1)))

ASSEMBLIES= \
        expand(DATA+"/assemblies/flye_{j}.fna", j=ASMS_INDICES_FLYE) \
        + expand(DATA+"/assemblies/minipolish_{j}.fna", j=ASMS_INDICES_MINIPOLISH) \
        + expand(DATA+"/assemblies/raven_{j}.fna", j=ASMS_INDICES_RAVEN)

# ------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------

rule all:
    input:
        directory(DATA+"/clusters"),
        DATA+"/inputs/raw_short_R1.fastq.gz",
        DATA+"/inputs/raw_short_R2.fastq.gz",


# ------------------------------------------------------------------------
# Collect inputs
# ------------------------------------------------------------------------

rule make_raw_nanopore:
    input: os.path.expanduser(config['nanopore'])
    output: DATA+"/inputs/raw_nanopore.fastq.gz"
    shell: "cat {input} > {output}"

rule make_raw_short_R1:
    input: os.path.expanduser(config['short_R1'])
    output: DATA+"/inputs/raw_short_R1.fastq.gz"
    shell: "cat {input} > {output}"

rule make_raw_short_R2:
    input: os.path.expanduser(config['short_R2'])
    output: DATA+"/inputs/raw_short_R2.fastq.gz"
    shell: "cat {input} > {output}"

# ------------------------------------------------------------------------
# Prep the Nanopore reads
# ------------------------------------------------------------------------


rule run_filtlong:
    input: DATA+"/inputs/raw_nanopore.fastq.gz",
    output: DATA+"/filtlong/filtered_nanopore.fastq.gz",
    threads: 9999
    conda: "envs/filtlong.yaml"
    shell:
        """
        filtlong --min_length 1000 --keep_percent 95 {input} \
            | {GZIP} > {output}
        """

rule filtlong_version:
    output: DATA+"/versions/filtlong.txt"
    conda: "envs/filtlong.yaml"
    shell:
        """
        filtlong --version 2>&1 | tee {output}
        """

# ------------------------------------------------------------------------
# subsample the reads
# ------------------------------------------------------------------------

rule run_trycycler_subsample:
    input: DATA+"/filtlong/filtered_nanopore.fastq.gz"
    output: directory(DATA+"/assemblies/inputs")
    threads: 9999
    conda: "envs/trycycler.yaml"
    shell:
        """
        trycycler subsample \
                  --genome_size {GENOME_SIZE} \
                  --reads {input} \
                  --out_dir {output} \
                  --count {NUM_ASMS} \
                  --threads {threads}
        {GZIP} {output}/*.fastq
        """

rule trycycler_version:
    output: DATA+"/versions/trycycler.txt"
    conda: "envs/trycycler.yaml"
    shell:
        """
        trycycler --version 2>&1 | tee {output}
        """
        
# ------------------------------------------------------------------------
# run flye
# ------------------------------------------------------------------------

rule run_flye:
    input: DATA+"/assemblies/inputs/sample_{j}.fastq.gz"
    output:
        fna=DATA+"/assemblies/flye_{j}.fna",
        tmp=directory(DATA+"/assemblies/flye_{j}")
    threads: 9999
    conda: "envs/flye.yaml"
    shell:
        """
        flye --nano-raw {input} --threads {threads} --out-dir {output.tmp}
        cp {output.tmp}/assembly.fasta {output.fna}
        """

# ------------------------------------------------------------------------
# run minipolish
# ------------------------------------------------------------------------

rule run_minipolish:
    input: DATA+"/assemblies/inputs/sample_{j}.fastq.gz"
    output:
        fna=DATA+"/assemblies/minipolish_{j}.fna",
        tmp=directory(DATA+"/assemblies/minipolish_{j}")
    threads: 9999
    conda: "envs/minipolish.yaml"
    shell:
        """
        rm -rf {output.tmp}
        mkdir -p {output.tmp}
        
        # cribbed from "miniasm_and_minipolish.sh", script written by Ryan
        # Wick <rrwick@gmail.com>. Taken from
        # https://github.com/rrwick/Minipolish/blob/main/miniasm_and_minipolish.sh
        # License under GPLv3

        # Find read overlaps with minimap2.
        minimap2 -x ava-ont -t {threads} {input} {input} \
                 > {output.tmp}/minipolish_overlap.paf

        # Run miniasm to make an unpolished assembly.
        miniasm -f {input} {output.tmp}/minipolish_overlap.paf \
                > {output.tmp}/minipolish_unpolished.gfa

        # Polish the assembly with minipolish, outputting the result to stdout.
        minipolish --threads {threads} {input} \
                   {output.tmp}/minipolish_unpolished.gfa \
                   > {output.tmp}/minipolish.gfa

        rm {output.tmp}/minipolish_overlap.paf \
           {output.tmp}/minipolish_unpolished.gfa

        any2fasta {output.tmp}/minipolish.gfa > {output.fna}
        """

# ------------------------------------------------------------------------
# run raven
# ------------------------------------------------------------------------

rule run_raven:
    input: DATA+"/assemblies/inputs/sample_{j}.fastq.gz"
    output:
        fna = DATA+"/assemblies/raven_{j}.fna",
        gfa = DATA+"/assemblies/raven_{j}.gfa",
    threads: 9999
    conda: "envs/raven.yaml"
    shell:
        """
        raven --threads {threads} \
              --graphical-fragment-assembly {output.gfa} \
 	      --disable-checkpoints \
              {input}  > {output.fna}
        """

# ------------------------------------------------------------------------
# cluster the contigs from the different assembles
# ------------------------------------------------------------------------

rule run_trycycler_cluster:
    input:
        assemblies=ASSEMBLIES,
        long_reads=DATA+"/filtlong/filtered_nanopore.fastq.gz"
    output: directory(DATA+"/clusters")
    params: config['cluster_args'] if 'cluster_args' in config else ''
    threads: 9999
    conda: "envs/trycycler.yaml"
    shell:
        """
        trycycler cluster \
            {params} \
            --threads {threads} \
            --assemblies {input.assemblies} \
            --reads {input.long_reads} \
            --out_dir {output}
        """
        
