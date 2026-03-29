#!/bin/bash

set -e

DOCKER_IMAGE=$1

if test -z "$DOCKER_IMAGE"; then
	DOCKER_IMAGE=espressif/idf:release-v4.2
fi

if ! git -C ./micropython rev-parse --git-dir >/dev/null 2>&1 || \
   ! git -C ./tensorflow rev-parse --git-dir >/dev/null 2>&1 || \
   ! git -C ./micropython-ulab rev-parse --git-dir >/dev/null 2>&1 || \
   ! git -C ./tflm_esp_kernels rev-parse --git-dir >/dev/null 2>&1; then
	echo "Bootstrapping pinned dependencies with ./setup-deps.sh"
	./setup-deps.sh
fi

winpty docker run -i -t -v /$(pwd):/src $DOCKER_IMAGE bash
