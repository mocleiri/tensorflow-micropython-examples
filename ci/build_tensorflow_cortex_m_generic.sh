#!/usr/bin/env bash
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
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
# Tests the microcontroller code using a Cortex-M4/M4F platform.

set -e

cd tensorflow

echo "current dir = $(pwd)"

source tensorflow/lite/micro/tools/ci_build/helper_functions.sh

TARGET=cortex_m_generic
OPTIMIZED_KERNEL_DIR=cmsis_nn

rm -rf tensorflow/lite/micro/tools/make/downloads

# TODO(b/143715361): downloading first to allow for parallel builds.
readable_run make -f tensorflow/lite/micro/tools/make/Makefile OPTIMIZED_KERNEL_DIR=${OPTIMIZED_KERNEL_DIR} TARGET=${TARGET} TARGET_ARCH=cortex-m4 third_party_downloads

readable_run make -f tensorflow/lite/micro/tools/make/Makefile clean

# Build for Cortex-M4 (FPU) with CMSIS
#readable_run make -j$(nproc) -f tensorflow/lite/micro/tools/make/Makefile \
#       OPTIMIZED_KERNEL_DIR=${OPTIMIZED_KERNEL_DIR} TARGET=${TARGET} TARGET_ARCH="cortex-m4+fp" microlite

# Build for Cortex-M7 (FPU) with CMSIS
readable_run make -j$(nproc) -f tensorflow/lite/micro/tools/make/Makefile \
CXXFLAGS="-DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -std=c++11 -Wno-error=incompatible-pointer-types -Wall -Wpointer-arith -Werror \
 -Wdouble-promotion -Wfloat-conversion -nostdlib  -Wno-error=discarded-qualifiers -Wno-error=unused-variable \
 -Wno-error=int-conversion -DSTM32H743xx -DUSE_FULL_LL_DRIVER -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard \
 -mtune=cortex-m7 -mcpu=cortex-m7 -Os -DNDEBUG -DSTM32_HAL_H='<stm32h7xx_hal.h>' -DMBOOT_VTOR=0x08000000 \
 -DMICROPY_HW_VTOR=0x08000000 \
 -fdata-sections -ffunction-sections -Os -MD " \
OPTIMIZED_KERNEL_DIR=${OPTIMIZED_KERNEL_DIR} TARGET=${TARGET} TARGET_ARCH="cortex-m7+fp" microlite
