#! /bin/bash

#! /bin/bash

. $(dirname ${BASH_SOURCE[0]})/doit-preamble.bash

# ------------------------------------------------------------------------
# Print final git info
# ------------------------------------------------------------------------

cd ${PIPELINE}

echo ''
(
    set -x
    git status
)
echo ''
(
    set -x
    git log -n1
)
