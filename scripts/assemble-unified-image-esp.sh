#!/bin/bash

BASE_DIR=$1
BUILD_DIR=$2

if test -z "$BASE_DIR"; then
	echo "USAGE: <Absolute Path to micropython/ports/esp32> <name of build dir>"
	exit 1
fi

if test -z "$BUILD_DIR"; then
	echo "USAGE: <Absolute Path to micropython/ports/esp32> <name of build dir>"
	exit 1
fi

python3 ${BASE_DIR}/makeimg.py \
${BASE_DIR}/build-${BUILD_DIR}/sdkconfig \
${BASE_DIR}/build-${BUILD_DIR}/bootloader/bootloader.bin \
${BASE_DIR}/build-${BUILD_DIR}/partition_table/partition-table.bin \
${BASE_DIR}/build-${BUILD_DIR}/micropython.bin \
${BASE_DIR}/build-${BUILD_DIR}/firmware.bin \
${BASE_DIR}/build-${BUILD_DIR}/micropython.uf2
