#!/bin/bash

DOCKER_IMAGE=$1

if test -z "$DOCKER_IMAGE"; then
	DOCKER_IMAGE=mocleiri/esp-idf-v4.0.1
fi

winpty docker run -i -t -v /$(pwd):/src $DOCKER_IMAGE bash

