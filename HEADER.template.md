---
title: FIXME
author: Paul Stodghill
date: FIXME
projects: FIXME
tags: 
...

# Results

Assemble statistics:

FIXME: put doit15.out stats here.

ReferenceSeeker results:

~~~
FIXME: put ReferenceSeeker results (doit11.out) here.
~~~

PGAP "taxcheck" results:

~~~
FIXME: PGAP ANI results (data/14_pgap/ani-tax-report.txt) here.
~~~


# Method

This is abbreviated. It needs to be flushed out.

This pipeline essentially follows the method suggested in the
[Trycycler documentation](https://github.com/rrwick/Trycycler/wiki).

Step 0. The input files were collected and stored within this directory
tree.

Step 1. FiltLong was used to trim and filter the
Nanopore reads.

Step 2. The reads were randomly subsampled to FIXMEx coverage (assuming
a 5Mb geneome) and initial draft assemblies were generated as follows:

- Canu: FIXME assemblies.
- Flye: FIXME assemblies.
- MiniPolish: FIXME assemblies.
- NECAT: FIXME assemblies.
- Raven: FIXME assemblies.
- Redbean: FIXME assemblies.

Step 3. `trycycler cluster` was used to group the unitigs for each of
the initial draft assemblies together.

Step 4. `trycycler reconcile` was used to circularize and rotate the
sequences within each cluster in preparation for computing a consensus
sequence. Problematic clusters, assemblies, and/or individual contigs,
were manually removed and this step was re-executions until all
clusters were reconciled. The following manual edits were needed to
obtain the final results:

- FIXME: drop in contents of `config04.bash`

Step 5. `trycycler msa` was used to computing an alignment of all of
the sequences within a cluster.

Step 6. `trycycler partition` was used to partition the long reads
between the clusters.

Step 7. `trycycler consensus` was used to compute a consensus sequence
for each of the clusters.

Step 8. Medaka was used to polish the assembly with the trimmed and
filtered long reads.

Step 9. (FIXME: was this step run?) FASTP was used to trim and filter
the Illumina reads.

Step 10. NextPolish was used to polish the assembly with trimmed and
filtered Illumin reads.

Step 11. (FIXME: was this step run?) ReferenceSeeker was used to
determine the most similar reference sequences.

Step 12. A completely independent assembly was construct using
Unicycler from the filtered and cleaned long and Illumina reads. This
`dnadiff` was used to compare the Trycycler and Unicycler assemblies.

Step 13. The sequences of the Trycycler assemble were "normalized":
(a) instances of the phi-X phage genome were removed; (b) the contigs
were renamed, "chromosome", "plasmidA", "plasmidB", etc., based on
sequence length; (c) sequences were rotated to put, e.g., DnaA near
position 1 on the positive strand.

Step 14. PGAP was used to annotate the final sequence.

If used at all, the following software versions were used:

- [Any2fasta](https://github.com/tseemann/any2fasta/) 0.4.2
- [Bowtie2](https://github.com/BenLangmead/bowtie2) 2.4.4
- [Canu](https://github.com/marbl/canu) 2.2
- [Entrez-direct](ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/versions/) 15.7.20210909
- [Emboss](http://emboss.sourceforge.net) 6.6.0
- [Fastp](https://github.com/OpenGene/fastp) 0.22.0
- [Filtlong](https://github.com/rrwick/Filtlong) 0.2.1
- [Flye](https://github.com/fenderglass/Flye) 2.9
- [Medaka](https://github.com/nanoporetech/medaka) 1.4.3
- [Minipolish](https://github.com/rrwick/Minipolish) 0.1.3
- [Mummer](http://mummer.sourceforge.net/) 3.23
- [Ncbi-blast](https://blast.ncbi.nlm.nih.gov/) 2.10.0+
- [Necat](https://github.com/xiaochuanle/NECAT) 20200803
- [Nextpolish](https://github.com/Nextomics/NextPolish) 1.3.1
- [PGAP](https://github.com/ncbi/pgap) FIXME
- [Raven](https://github.com/lbcb-sci/raven/) 1.5.1
- [Referenceseeker](https://github.com/oschwengers/referenceseeker) 1.7.3

    + RefSeq DB release FIXME
    + GTDB DB release FIXME

- [Samtools](https://github.com/samtools/samtools) 1.14
- [Seqtk](https://github.com/lh3/seqtk) 1.3
- [Trycycler](https://github.com/rrwick/Trycycler) 0.5.1
- [Unicycler](https://github.com/rrwick/Unicycler) 0.4.9
- [Wtdbg2 (Redbean)](https://github.com/ruanjue/wtdbg2 (redbean)) 2.5

