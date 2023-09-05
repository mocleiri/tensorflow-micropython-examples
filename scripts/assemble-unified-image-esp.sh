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
${BUILD_DIR}/sdkconfig \
${BUILD_DIR}/bootloader/bootloader.bin \
${BUILD_DIR}/partition_table/partition-table.bin \
${BUILD_DIR}/micropython.bin \
${BUILD_DIR}/firmware.bin \
${BUILD_DIR}/micropython.uf2
