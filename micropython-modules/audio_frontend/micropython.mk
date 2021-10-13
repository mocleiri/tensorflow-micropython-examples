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
AUDIO_FRONTEND_MOD_DIR := $(USERMOD_DIR)

# current working directory seems to be micropython/ports/esp32 when this is run
TENSORFLOW := ../../../tensorflow

ULAB := ../../../micropython-ulab

# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/micro/tools/make/downloads/kissfft/kiss_fft.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/micro/tools/make/downloads/kissfft/tools/kiss_fftr.c

SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/filterbank.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/filterbank_util.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/frontend.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/frontend_util.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/log_lut.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/log_scale.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/log_scale_util.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/noise_reduction.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/noise_reduction_util.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control_util.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/window.c
SRC_USERMOD += $(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib/window_util.c

SRC_USERMOD += $(AUDIO_FRONTEND_MOD_DIR)/audio_frontend_module.c

SRC_USERMOD_CXX += $(AUDIO_FRONTEND_MOD_DIR)/fft.cpp
SRC_USERMOD_CXX += $(AUDIO_FRONTEND_MOD_DIR)/fft_util.cpp

# needed with c++
#LDFLAGS_USERMOD += -lsupc++

CFLAGS_USERMOD += -I$(AUDIO_FRONTEND_MOD_DIR)
CFLAGS_USERMOD += -I$(TENSORFLOW)/tensorflow/lite/micro/tools/make/downloads/kissfft
CFLAGS_USERMOD += -I$(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib
CFLAGS_USERMOD += -I$(ULAB)/code
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow

CFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1

CFLAGS_USERMOD += -Wno-error=float-conversion
CFLAGS_USERMOD += -Wno-error=nonnull
CFLAGS_USERMOD += -Wno-error=double-promotion
CFLAGS_USERMOD += -Wno-error=pointer-arith
CFLAGS_USERMOD += -Wfloat-conversion

CXXFLAGS_USERMOD += -I$(AUDIO_FRONTEND_MOD_DIR)
CXXFLAGS_USERMOD += -I$(TENSORFLOW)/tensorflow/lite/micro/tools/make/downloads/kissfft
CXXFLAGS_USERMOD += -I$(TENSORFLOW)/tensorflow/lite/experimental/microfrontend/lib
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow

CXXFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1

CXXFLAGS_USERMOD += -Wfloat-conversion

# unix port
CFLAGS_USERMOD += -Wno-error=unused-const-variable

override CFLAGS_EXTRA += -DMODULE_AUDIO_FRONTEND_ENABLED=1

#PART_SRC=$(MFCC_MOD_DIR)/../../partitions-2MiB.csv
