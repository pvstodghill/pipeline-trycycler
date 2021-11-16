# pipeline-trycycler

Pipeline for assembling prokaryotic genomes using
[Trycycler](https://github.com/rrwick/Trycycler).

Setting a [Conda](https://conda.io) environment for the pipeline,

```
# conda env remove -y --name pipeline-trycycler
conda create -y --name pipeline-trycycler
conda activate pipeline-trycycler

conda config --add channels bioconda
conda config --add channels conda-forge

# required
conda install -y "samtools>=1.10"
conda install -y any2fasta
conda install -y blast
conda install -y emboss
conda install -y entrez-direct
conda install -y fastp=0.22.0 # <-- for me 0.23.x hangs
conda install -y filtlong
conda install -y medaka
conda install -y seqtk
conda install -y trycycler

# very strongly encouraged
conda install -y flye
conda install -y minipolish miniasm
conda install -y raven-assembler

# encouraged
conda install -y unicycler mummer
conda install -y referenceseeker

# optional
conda install -y canu
conda install -y wtdbg
conda install -y necat

```

Now install [NextPolish](https://github.com/Nextomics/NextPolish) and
add its directory to the `\$PATH`.
