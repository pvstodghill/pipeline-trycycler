#! /bin/bash

PACKAGE=$(grep -E '^ENV +PACKAGE +' Dockerfile | sed -r -e 's/ENV +PACKAGE +//' | tr '[A-Z]' '[a-z]')
IMAGE=pvstodghill/$PACKAGE
RELEASE=$(date +%Y-%m-%d)

fulltag=$(echo ${IMAGE}:${RELEASE})

set -x
set -e

docker build --pull -t ${fulltag} .
#set +e
docker run --rm -w /tmp/. ${fulltag} conda list
#set -e
docker push ${fulltag}
docker tag ${fulltag} ${IMAGE}:latest
docker push ${IMAGE}:latest

