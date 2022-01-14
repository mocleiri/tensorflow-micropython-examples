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

TF_BOARD := NOT_SUPPORTED

ifndef ($(BOARD))

ifeq ($(UNAME_S),Linux)

	BOARD ?= unix
	TF_BOARD = STANDARD
endif

endif


ifeq ($(BOARD),NUCLEO_H743ZI2_MICROLITE)
  TF_BOARD = CMSIS_NN

  CXXFLAGS_USERMOD += -DARM_MATH_CM7
  CFLAGS_USERMOD += -DARM_MATH_CM7

  CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/stm32lib
  CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/stm32lib

  LDFLAGS_USERMOD += -lm -lstdc++

endif

ifeq ($(BOARD),NUCLEO_F446RE_MICROLITE)
  TF_BOARD = CMSIS_NN

  CFLAGS_USERMOD += -Wno-error=attributes -Wno-error=unused-function

  CXXFLAGS_USERMOD += -DARM_MATH_CM4
  CFLAGS_USERMOD += -DARM_MATH_CM4

  CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/stm32lib
  CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/stm32lib

  LDFLAGS_USERMOD +=  -lm -lstdc++ --unresolved-symbols=ignore-all
  
  # map all source files here for total control over size
  SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/schema/schema_utils.cpp

  # provides audio front-end spectrogram

  SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/log_scale_util.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/frontend_util.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/filterbank_util.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/log_scale.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/filterbank.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/window.c
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/kiss_fft_int16.cpp
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/window_util.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control_util.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/frontend.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/noise_reduction_util.c
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/fft_util.cpp
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/noise_reduction.c
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/fft.cpp
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/experimental/microfrontend/lib/log_lut.c

  # end of microfrontent spectrogram provider

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/kernels/internal/quantization_util.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/kernels/internal/reference/portable_tensor_utils.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/kernels/kernel_util.cpp

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_utils.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/flatbuffer_utils.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/recording_simple_memory_allocator.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_string.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_profiler.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_allocator.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/simple_memory_allocator.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/test_helpers.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_resource_variable.cpp

# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/dequantize.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/quantize.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/elu.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/pooling_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/expand_dims.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/hard_swish.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/conv_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/call_once.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/gather.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/comparisons.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/ceil.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/kernel_runner.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/mul_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/gather_nd.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/maximum_minimum.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/logical_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/depthwise_conv_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/logistic_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/transpose.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/split.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/zeros_like.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/if.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/fill.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/floor_div.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/svdf_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cast.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/pad.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/read_variable.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/sub_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/activations_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/logistic.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/activations.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/slice.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/floor.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/strided_slice.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/circular_buffer.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/elementwise.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/unpack.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/space_to_depth.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/arg_min_max.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/round.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/leaky_relu.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/split_v.cpp

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/fully_connected.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/pooling.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/softmax.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/depthwise_conv.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/conv.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/mul.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/add.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn/svdf.cpp

# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cumsum.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/prelu_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/circular_buffer_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/batch_to_space_nd.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/kernel_util.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/softmax_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/exp.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/var_handle.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/detection_postprocess.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/resize_nearest_neighbor.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/tanh.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/depth_to_space.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/ethosu.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/log_softmax.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/add_n.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/neg.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/add_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/leaky_relu_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/shape.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/pack.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/reshape.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/sub.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/space_to_batch_nd.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/floor_mod.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/squeeze.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/prelu.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/hard_swish_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/reduce.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/l2norm.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/concatenation.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/resize_bilinear.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/quantize_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/fully_connected_common.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/dequantize_common.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/logical.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/assign_variable.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/transpose_conv.cpp

# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/recording_micro_allocator.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_interpreter.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_graph.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/all_ops_resolver.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/memory_helpers.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/micro_error_reporter.cpp
# SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/mock_micro_graph.cpp

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/memory_planner/linear_memory_planner.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/memory_planner/greedy_memory_planner.cpp

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/cortex_m_generic/debug_log.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/cortex_m_generic/micro_time.cpp

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/system_setup.cpp

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/core/api/error_reporter.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/core/api/op_resolver.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/core/api/flatbuffer_conversions.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/core/api/tensor_utils.cpp

SRC_USERMOD += $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/c/common.c

endif


# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tensorflow-microlite.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/audio_frontend.c


SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/openmv-libtf.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/libtf-op-resolvers.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/micropython-error-reporter.cpp

ifeq ($(TF_BOARD),CMSIS_NN)

SRC_USERMOD += $(MICROLITE_MOD_DIR)/../../micropython/shared/libc/__errno.c

SRC_USERMOD += $(MICROLITE_MOD_DIR)/xalloc.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/mpy_heap_malloc.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/bare-metal-gc-heap.c

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/mpy_heap_new_delete.cpp

# LIBC_FILE_NAME   = $(shell $(CC) $(CFLAGS_USERMOD) -print-file-name=libc.a)

# LDFLAGS_USERMOD += -L $(shell dirname $(LIBC_FILE_NAME)) -lc -lm -lstdc++

# LDFLAGS_USERMOD += -lm -lstdc++

SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/bsearch.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/strtoll.c
SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/strtoull.c

SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/ctype_.c

# additional musl math functions needed by tensorflow
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/cosf.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/expf.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/expm1f.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/logf.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/nan.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/powf.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/sinf.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/sqrtf.c

# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/exp2f_data.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/logf_data.c
# SRC_USERMOD += $(MICROLITE_MOD_DIR)/stm32lib/sqrt_data.c

# CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../micropython/lib/libm
# CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/stm32lib

endif

ifeq ($(BOARD),unix)

CFLAGS_USERMOD += -Wno-error=sign-compare
CXXFLAGS_USERMOD += -Wno-error=sign-compare

LDFLAGS_USERMOD += -lm -lstdc++

endif


ifneq ($(BOARD),NUCLEO_F446RE_MICROLITE)
SRC_USERMOD += $(shell find $(MICROLITE_MOD_DIR)/tflm/tensorflow -name "*.c")
endif

SRC_USERMOD += $(shell find $(MICROLITE_MOD_DIR)/tflm/third_party -name "*.c")

$(info TF_BOARD = $(TF_BOARD))
$(info BOARD = $(BOARD))





# This is not quite right.  this needs to be included if the build is for stm32
#SRC_USERMOD += $(MICROLITE_MOD_DIR)/xalloc.c
#SRC_USERMOD += $(MICROLITE_MOD_DIR)/mpy_heap_malloc.c
#SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/mpy_heap_new_delete.cpp

ifeq ($(TF_BOARD),CMSIS_NN)

PATH_TO_OPTIMIZED_KERNELS := $(MICROLITE_MOD_DIR)/tflm/tensorflow/lite/micro/kernels/cmsis_nn

ifneq ($(BOARD),NUCLEO_F446RE_MICROLITE)

TF_MICROLITE_SRCS := $(shell find $(MICROLITE_MOD_DIR)/tflm/tensorflow -name "*.cpp" | grep -v all_ops_resolver)

SRC_USERMOD_CXX +=  $(shell python3 $(MICROLITE_MOD_DIR)/../../tensorflow/tensorflow/lite/micro/tools/make/specialize_files.py \
		--base_files "$(TF_MICROLITE_SRCS)" \
		--specialize_directory $(PATH_TO_OPTIMIZED_KERNELS))

endif

#  $(info TF_MICROLITE_SPECIALIZED_SRCS = $(TF_MICROLITE_SPECIALIZED_SRCS))

# For CMSIS_NN: 
 
SRC_USERMOD += $(shell find $(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/NN/Source -name "*.c")
SRC_USERMOD_CXX += $(shell find $(MICROLITE_MOD_DIR)/tflm/third_party/cmsis/CMSIS/NN/Source -name "*.cpp"  | grep -v all_ops_resolver)

endif

ifeq ($(TF_BOARD),STANDARD)
# For Standard:

# for now lets just use the reference kernels
SRC_USERMOD_CXX += $(shell find $(MICROLITE_MOD_DIR)/tflm/tensorflow -name "*.cpp")

$(info "SRC_USERMOD_CXX = $(SRC_USERMOD_CXX)" )
endif

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)

CFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1
CXXFLAGS_USERMOD += -DTF_LITE_STATIC_MEMORY=1

CXXFLAGS_USERMOD += -fno-rtti -fno-exceptions

CFLAGS_USERMOD += -Wno-error=discarded-qualifiers

# caused by  audio_frontend
CFLAGS_USERMOD += -Wno-error=double-promotion

CFLAGS_USERMOD += -Wno-error=unused-variable
CFLAGS_USERMOD += -Wno-error=int-conversion
CFLAGS_USERMOD += -Wno-error=incompatible-pointer-types
CFLAGS_USERMOD += -Wno-error=float-conversion
CFLAGS_USERMOD += -Wno-error=unused-const-variable=

# CFLAGS_USERMOD += -fno-builtin

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

ifeq ($(TF_BOARD),CMSIS_NN)

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

# needed by CMSIS NN complaints
CFLAGS_USERMOD += -Wno-error=implicit-function-declaration
CXXFLAGS_USERMOD += -Wno-error=sign-compare
CXXFLAGS_USERMOD += -Wno-error=unused-but-set-variable
CXXFLAGS_USERMOD += -Wno-error=float-conversion
CXXFLAGS_USERMOD += -Wno-error=deprecated-declarations


override CFLAGS_EXTRA += -DMODULE_MICROLITE_ENABLED=1

