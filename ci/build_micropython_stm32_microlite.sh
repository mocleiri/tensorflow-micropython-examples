# Copyright 2021 The TensorFlow Micropython Examples rs. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# Tests the microcontroller code for stm32 platform

set -e

BASE_DIR=/opt/tflite-micro-micropython

python3 ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
--makefile_options="TARGET=cortex_m_generic TARGET_ARCH=project_generation OPTIMIZED_KERNEL_DIR=cmsis_nn" \
--examples micro_speech --rename-cc-to-cpp $BASE_DIR/micropython-modules/microlite/tflm

cd $BASE_DIR/tensorflow

# get the dependencies needed by
make -f tensorflow/lite/micro/tools/make/Makefile third_party_downloads


mkdir $BASE_DIR/c-modules

cd $BASE_DIR/c-modules

ln -s ../micropython-ulab/code ulab
ln -s ../micropython-modules/microlite microlite

cd $BASE_DIR/micropython/ports/stm32

pwd

make V=1 submodules


cd $BASE_DIR/micropython

echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all


echo "cd $BASE_DIR/boards/esp32/MICROLITE"
cd $BASE_DIR/boards/stm32/NUCLEO_H743ZI2_MICROLITE

pwd

echo "Building NUCLEO_H743ZI2_MICROLITE"
rm -rf build
make V=1
