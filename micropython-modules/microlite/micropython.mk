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

TF_OPTIMIZATION := Standard

$(info TF_OPTIMIZATION = $(TF_OPTIMIZATION))
$(info BOARD = $(BOARD))

# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tensorflow-microlite.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/audio_frontend.c


SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/openmv-libtf.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/micropython-error-reporter.cpp

ifeq ($(BOARD), NUCLEO_H743ZI2_MICROLITE)

SRC_USERMOD += $(MICROLITE_MOD_DIR)/../../micropython/shared/libc/__errno.c

SRC_USERMOD += $(MICROLITE_MOD_DIR)/xalloc.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/mpy_heap_malloc.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/bare-metal-gc-heap.c

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/mpy_heap_new_delete.cpp




endif

SRC_USERMOD += $(shell find $(MICROLITE_MOD_DIR)/tflm/tensorflow -name "*.c")
SRC_USERMOD += $(shell find $(MICROLITE_MOD_DIR)/tflm/third_party -name "*.c")

ifeq ($(BOARD), NUCLEO_H743ZI2_MICROLITE)



# This is not quite right.  this needs to be included if the build is for stm32
#SRC_USERMOD += $(MICROLITE_MOD_DIR)/xalloc.c
#SRC_USERMOD += $(MICROLITE_MOD_DIR)/mpy_heap_malloc.c
#SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/mpy_heap_new_delete.cpp

ifeq ($(TF_OPTIMIZATION),CMSIS_NN)

PATH_TO_OPTIMIZED_KERNELS := $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn

TF_MICROLITE_SRCS := $(shell find $(MICROLITE_MOD_DIR)/tflm/tensorflow -name "*.cpp" )

SRC_USERMOD_CXX +=  $(shell python3 $(MICROLITE_MOD_DIR)/../../tensorflow/tensorflow/lite/micro/tools/make/specialize_files.py \
		--base_files "$(TF_MICROLITE_SRCS)" \
		--specialize_directory $(PATH_TO_OPTIMIZED_KERNELS))

#  $(info TF_MICROLITE_SPECIALIZED_SRCS = $(TF_MICROLITE_SPECIALIZED_SRCS))

# For CMSIS_NN: 
 
SRC_USERMOD += $(shell find $(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/NN/Source -name "*.c")
SRC_USERMOD_CXX += $(shell find $(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/NN/Source -name "*.cpp")

endif

ifeq ($(TF_OPTIMIZATION),Standard)
# For Standard:

# for now lets just use the reference kernels
SRC_USERMOD_CXX += $(shell find $(MICROLITE_MOD_DIR)/tflm/tensorflow -name "*.cpp")

$(info "SRC_USERMOD_CXX = $(SRC_USERMOD_CXX)" )
endif


endif


CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)

CFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1
CXXFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1

CXXFLAGS_USERMOD += -fno-rtti -fno-exceptions

CFLAGS_USERMOD += -Wno-error=discarded-qualifiers

# caused by  audio_frontend
CFLAGS_USERMOD += -Wno-error=double-promotion

# unix port
CFLAGS_USERMOD += -Wno-error=unused-variable
CFLAGS_USERMOD += -Wno-error=int-conversion
CFLAGS_USERMOD += -Wno-error=incompatible-pointer-types
CFLAGS_USERMOD += -Wno-error=float-conversion
CFLAGS_USERMOD += -Wno-error=unused-const-variable=

CFLAGS_USERMOD += -fno-builtin

CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/flatbuffers/include

CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/gemmlowp
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/ruy

# general flags for tensorflow lite micro:
CXXFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY 
CXXFLAGS_USERMOD += -DNDEBUG 
CXXFLAGS_USERMOD += -DTF_LITE_MCU_DEBUG_LOG 

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/kissfft
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/kissfft/tools

# if we are building for cortex h7

ifeq ($(BOARD), NUCLEO_H743ZI2_MICROLITE)

CXXFLAGS_USERMOD += -D __FPU_PRESENT=1 
CXXFLAGS_USERMOD += -DARM_MATH_CM7

ifeq ($(TF_OPTIMIZATION),CMSIS_NN)

CXXFLAGS_USERMOD += -DCMSIS_NN

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/Core/Include
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/NN/Include
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/DSP/Include

CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/Core/Include
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/NN/Include
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/DSP/Include
endif

endif

# needed by CMSIS NN complaints
CFLAGS_USERMOD += -Wno-error=implicit-function-declaration

CXXFLAGS_USERMOD += -Wno-error=sign-compare
CXXFLAGS_USERMOD += -Wno-error=float-conversion

#CXXFLAGS_USERMOD += -g

# unix port
CXXFLAGS_USERMOD += -Wno-error=deprecated-declarations
#CXXFLAGS_USERMOD += -fno-permissive
#CXXFLAGS_USERMOD += -Wwarning=permissive



override CFLAGS_EXTRA += -DMODULE_MICROLITE_ENABLED=1

