#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Run ReferenceSeeker
# ------------------------------------------------------------------------

if [ "$REFSEEK" ] ; then
    echo '# Running ReferenceSeeker...'
    REFSEEK="$REFSEEK" \
	   ${PIPELINE}/scripts/run-referenceseeker ${DATA}/assembly.fasta
fi
    
# ------------------------------------------------------------------------
# Done.
# ------------------------------------------------------------------------

echo 1>&2 ''
echo 1>&2 '# Done.'

