#!/bin/bash

DOCKER_IMAGE=$1

if test -z "$DOCKER_IMAGE"; then
	DOCKER_IMAGE=espressif/idf:release-v4.2
fi

winpty docker run -i -t -v /$(pwd):/src $DOCKER_IMAGE bash

