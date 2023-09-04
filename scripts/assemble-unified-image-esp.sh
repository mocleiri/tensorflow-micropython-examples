#!/bin/bash

BASE_DIR=$1

if test -z "$BASE_DIR"; then
	echo "USAGE: <Absolute Path to micropython/ports/esp32>"
	exit 1
fi


python3 ${BASE_DIR}/makeimg.py \
build/sdkconfig \
build/bootloader/bootloader.bin \
build/partition_table/partition-table.bin \
build/micropython.bin \
build/firmware.bin \
build/micropython.uf2
