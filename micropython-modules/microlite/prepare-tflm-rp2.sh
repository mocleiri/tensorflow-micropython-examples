#!/bin/bash
# needs to be run from the tensorflow top level directory

rm -rf ./tensorflow/lite/micro/tools/make/downloads
rm -rf ./tensorflow/lite/micro/tools/make/gen
rm -rf ../micropython-modules/microlite/tflm

python3 ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
	--makefile_options="TARGET=cortex_m_generic TARGET_ARCH=project_generation" \
       	--examples micro_speech --rename-cc-to-cpp ../micropython-modules/microlite/tflm
