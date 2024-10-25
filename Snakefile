import os

configfile: "config.template.yaml" # fixme!

DATA=config['data'] if 'data' in config else "data"
PIPELINE=os.path.dirname(workflow.snakefile)

# ------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------

rule all:
    input:
        DATA+"/inputs/raw_nanopore.fastq.gz",
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

