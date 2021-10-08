#
# This file is part of the Tensorflow Micropython Examples Project.
#
# The MIT License (MIT)
#
# Copyright (c) 2021 Michael O'Cleirigh
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#/
MICROLITE_MOD_DIR := $(USERMOD_DIR)

# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tensorflow-microlite.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/bare-metal-gc-heap.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/../../micropython/shared/libc/__errno.c
#SRC_USERMOD += $(MICROLITE_MOD_DIR)/../../micropython/shared/libc/string0.c

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/openmv-libtf.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/micropython-error-reporter.cpp

LDFLAGS_USERMOD += -L /home/mike/git/tensorflow-micropython-examples/lib -ltensorflow-microlite

# may need to incorporate from: https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/tools/project_generation/Makefile
# This will generate for cortex_m_generic and all of the files
# python3 ./tensorflow/lite/micro/tools/project_generatio
#n/create_tflm_tree.py --makefile_options="TARGET=cortex_m_generic TARGET_ARCH=project_generation OPTIMI
#ZED_KERNEL_DIR=cmsis_nn" --examples micro_speech --rename-cc-to-cpp /opt/tflite-micro/micropython-modul
#es/microlite/tflm


# TARGET=cortex_m_generic
# OPTIMIZED_KERNEL_DIR=cmsis_nn
# TARGET_ARCH="cortex-m7+fp
# option from micropython
# -mfpu=fpv5-d16 -mfloat-abi=hard

$(shell PYTHON ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
--makefile_options="TARGET=cortex_m_generic TARGET_ARCH=project_generation OPTIMIZED_KERNEL_DIR=cmsis_nn" \
--examples micro_speech --rename-cc-to-cpp tflm)
# needed with c++
LDFLAGS_USERMOD += -lstdc++_nano -lm
#LDFLAGS_USERMOD += -lstdc++_nano -lm

# this path is valid if used within the esp-idf-4.0.1 docker container


CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)

CFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1
CXXFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow

CFLAGS_USERMOD += -Wno-error=discarded-qualifiers

# unix port
CFLAGS_USERMOD += -Wno-error=unused-variable
CFLAGS_USERMOD += -Wno-error=int-conversion
CFLAGS_USERMOD += -Wno-error=incompatible-pointer-types


CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow/tensorflow/lite/micro/tools/make/downloads/flatbuffers/include
CXXFLAGS_USERMOD += -Wno-error=sign-compare
#CXXFLAGS_USERMOD += -g

# unix port
CXXFLAGS_USERMOD += -Wno-error=deprecated-declarations
#CXXFLAGS_USERMOD += -fno-permissive
#CXXFLAGS_USERMOD += -Wwarning=permissive


override CFLAGS_EXTRA += -DMODULE_MICROLITE_ENABLED=1

