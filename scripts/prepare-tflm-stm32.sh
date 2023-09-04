#!/bin/bash

rm -rf ./tensorflow/lite/micro/tools/make/downloads
rm -rf ./tensorflow/lite/micro/tools/make/gen
rm -rf ../micropython-modules/microlite/tflm

# add the following to makefile_options OPTIMIZED_KERNEL_DIR=cmsis_nn to build the optimized
# kernels
# however we need a lot more of the math library to support it.
python3 ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
	--makefile_options="TARGET=cortex_m_generic OPTIMIZED_KERNEL_DIR=cmsis_nn  TARGET_ARCH=cortex-m7" \
       	--examples micro_speech --rename_cc_to_cpp ../micropython-modules/microlite/tflm

# we need to update the CMSIS-Core files to use the ones that were downloaded 
cp ../micropython-modules/microlite/tflm/third_party/cmsis/CMSIS/Core/Include/* ../micropython/lib/cmsis/inc