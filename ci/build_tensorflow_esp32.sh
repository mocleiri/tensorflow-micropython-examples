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

BASE_DIR=/opt/tflite-micro-micropython

cd $BASE_DIR/tensorflow

make -f tensorflow/lite/micro/tools/make/Makefile \
CXXFLAGS="-std=c++11 -DNDEBUG -fstrict-volatile-bitfields -mlongcalls -nostdlib -fno-rtti -fno-exceptions -fno-threadsafe-statics -fno-unwind-tables -ffunction-sections -fdata-sections -fmessage-length=0 -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -Werror -Wsign-compare -Wdouble-promotion -Wshadow -Wunused-variable -Wmissing-field-initializers -Wunused-function -Wswitch -Wvla -Wall -Wextra -Wstrict-aliasing -Wno-unused-parameter -DESP -Wno-return-type -Wno-strict-aliasing -Wno-ignored-qualifiers -Wno-return-type  -Wno-strict-aliasing" \
TARGET_TOOLCHAIN_PREFIX=xtensa-esp32-elf- TARGET=esp TARGET_ARCH=xtensa-esp32 clean

rm -rf tensorflow/lite/micro/tools/make/downloads

make -f tensorflow/lite/micro/tools/make/Makefile \
CXXFLAGS="-std=c++11 -DNDEBUG -fstrict-volatile-bitfields -mlongcalls -nostdlib -fno-rtti -fno-exceptions -fno-threadsafe-statics -fno-unwind-tables -ffunction-sections -fdata-sections -fmessage-length=0 -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -Werror -Wsign-compare -Wdouble-promotion -Wshadow -Wunused-variable -Wmissing-field-initializers -Wunused-function -Wswitch -Wvla -Wall -Wextra -Wstrict-aliasing -Wno-unused-parameter -DESP -Wno-return-type -Wno-strict-aliasing -Wno-ignored-qualifiers -Wno-return-type  -Wno-strict-aliasing" \
TARGET_TOOLCHAIN_PREFIX=xtensa-esp32-elf- TARGET=esp TARGET_ARCH=xtensa-esp32 

echo "cp tensorflow/lite/micro/tools/make/gen/esp_xtensa-esp32_default/lib/libtensorflow-microlite.a $BASE_DIR/lib"
cp tensorflow/lite/micro/tools/make/gen/esp_xtensa-esp32_default/lib/libtensorflow-microlite.a $BASE_DIR/lib

echo "ls $BASE_DIR/lib"
ls $BASE_DIR/lib



