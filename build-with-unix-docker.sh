#!/bin/bash

DOCKER_IMAGE=$1

if test -z "$DOCKER_IMAGE"; then
	# need to build the docker/unix-build image first
	DOCKER_IMAGE=unix-build
fi

winpty docker run -i -t -v /$(pwd):/src  --entrypoint "bash" $DOCKER_IMAGE

