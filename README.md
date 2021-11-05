# pipeline-trycycler

Pipeline for assembling prokaryotic genomes using
[Trycycler](https://github.com/rrwick/Trycycler).

Setting a [Conda](https://conda.io) environment for the pipeline,

```
# conda env remove -y --name trycycler
conda create -y --name trycycler
conda activate trycycler

conda config --add channels bioconda
conda config --add channels conda-forge

conda install -y any2fasta
conda install -y filtlong
conda install -y flye
conda install -y miniasm
conda install -y minipolish
conda install -y raven-assembler
conda install -y seqtk
conda install -y trycycler

conda install -y canu
```

