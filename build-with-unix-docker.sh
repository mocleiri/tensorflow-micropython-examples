#!/bin/bash

DOCKER_IMAGE=$1

if test -z "$DOCKER_IMAGE"; then
	DOCKER_IMAGE=madduci/docker-linux-cpp
fi

winpty docker run -i -t -v /$(pwd):/src  --entrypoint "bash" $DOCKER_IMAGE

