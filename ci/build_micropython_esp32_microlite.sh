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
# Tests the microcontroller code for esp32 platform

set -e

BASE_DIR=$(pwd)

echo "BASE_DIR=$BASE_DIR"

cd $BASE_DIR/tensorflow

echo "Regenerating microlite/tfm directory"
rm -rf $BASE_DIR/micropython-modules/microlite/tflm

python3 ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
--makefile_options="TARGET_TOOLCHAIN_PREFIX=xtensa-esp32-elf- TARGET=esp TARGET_ARCH=xtensa-esp32" \
--examples micro_speech --rename-cc-to-cpp $BASE_DIR/micropython-modules/microlite/tflm


cd $BASE_DIR/micropython

pwd

echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all


echo "cd $BASE_DIR/boards/esp32/MICROLITE"
cd $BASE_DIR/boards/esp32/MICROLITE

pwd

echo "Building MICROLITE"
rm -rf builds
idf.py clean build
