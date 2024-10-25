import os

configfile: "config.template.yaml" # fixme!

DATA=config['data'] if 'data' in config else "data"
PIPELINE=os.path.dirname(workflow.snakefile)

GZIP="pigz"

# ------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------

rule all:
    input:
        DATA+"/filtlong/filtered_nanopore.fastq.gz",
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

