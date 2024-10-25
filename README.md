# pipeline-trycycler

Pipeline for assembling prokaryotic genomes using
[Trycycler](https://github.com/rrwick/Trycycler).

## Cloning the repo

This pipeline using Git submodules. The easiest way to clone this repo (with a recent version of `git`) is

```
git clone --recurse-submodules https://github.com/pvstodghill/pipeline-trycycler.git
```

## Installing prereqs

One of the following:

<!-- - [Docker](https://www.docker.com/) -->
<!-- - [Singularity](https://sylabs.io/) -->
<!-- - [Apptainer](https://apptainer.org/) -->
- [Conda](https://conda.io)

You will also need,

- [Snakemake](https://snakemake.readthedocs.io/)
- [Perl](https://www.perl.org/)
- [Perl's YAML module](https://metacpan.org/dist/YAML)

## Configuring the pipeline

**Create the configuration files**

To run the pipeline on your own data,

1. Copy `config.template.yaml` to `config.yaml`.  Edit `config.yaml` according to your needs and local environment.

FIXME: document the rest of the config files

## Running the pipeline

To run the pipeline using local copies of the software components:

~~~
snakemake
~~~

To run the pipeline using [Conda](https://conda.io) to provide software components:

~~~
snakemake --use-conda
~~~

To run the pipeline using [Mamba](https://mamba.readthedocs.io) to provide software components:

~~~
snakemake --use-conda --conda-frontend mamba
~~~

## Software components

The following software is used by this pipeline,

- FIXME
