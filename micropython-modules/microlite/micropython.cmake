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

get_filename_component(TENSORFLOW_DIR ${PROJECT_DIR}/../../../tensorflow ABSOLUTE)

add_library(microlite INTERFACE)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")

# needed when we have custom/specialized kernels.
# add_custom_command(
#     OUTPUT ${TF_MICROLITE_SPECIALIZED_SRCS}
#     COMMAND cd ${TENSORFLOW_DIR} && ${Python3_EXECUTABLE} ${MICROPY_DIR}/py/makeversionhdr.py ${MICROPY_MPVERSION}
#     DEPENDS MICROPY_FORCE_BUILD
# )


target_sources(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp
    # TODO: see if we can determine this list at runtime
    # find ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow -name "*.c" | grep  -v experimental
    # find ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow -name "*.cpp" | grep  -v experimental
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/c/common.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/filterbank.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/filterbank_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/frontend_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/log_lut.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/log_scale.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/log_scale_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/noise_reduction.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/noise_reduction_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/window.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/window_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft/kiss_fft.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft/tools/kiss_fftr.c

    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/error_reporter.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/flatbuffer_conversions.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/op_resolver.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/tensor_utils.cpp
#    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/fft.cpp
#    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/fft_util.cpp
#    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/kiss_fft_int16.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/kernels/internal/quantization_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/kernels/internal/reference/portable_tensor_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/kernels/kernel_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/all_ops_resolver.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/flatbuffer_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/activations.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/activations_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add_n.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/arg_min_max.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/assign_variable.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/batch_to_space_nd.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/call_once.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cast.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/ceil.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/circular_buffer.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/circular_buffer_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/comparisons.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/concatenation.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cumsum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depth_to_space.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/dequantize.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/detection_postprocess.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/elementwise.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/elu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/ethosu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/exp.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/expand_dims.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fill.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/floor.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/floor_div.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/floor_mod.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/gather.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/gather_nd.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/hard_swish.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/hard_swish_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/if.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/kernel_runner.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/kernel_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2norm.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/leaky_relu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/leaky_relu_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logical.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logical_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logistic.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logistic_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/log_softmax.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/maximum_minimum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mul.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mul_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/neg.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pack.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pad.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/prelu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/quantize.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/quantize_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/read_variable.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/reduce.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/reshape.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/resize_bilinear.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/resize_nearest_neighbor.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/round.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/shape.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/softmax.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/softmax_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/space_to_batch_nd.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/space_to_depth.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/split.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/split_v.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/squeeze.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/strided_slice.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/sub.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/sub_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/svdf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/svdf_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/tanh.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/transpose.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/transpose_conv.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/unpack.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/var_handle.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/zeros_like.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_helpers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_planner/greedy_memory_planner.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_planner/linear_memory_planner.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_error_reporter.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_graph.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_interpreter.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_profiler.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_resource_variable.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_string.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/mock_micro_graph.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/recording_micro_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/recording_simple_memory_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/simple_memory_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/system_setup.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/test_helpers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/schema/schema_utils.cpp


)

target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/tflm
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft/tools
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/flatbuffers/include
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/gemmlowp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/ruy
)

target_compile_definitions(microlite INTERFACE
    MODULE_MICROLITE_ENABLED=1
    TF_LITE_STATIC_MEMORY=1
    DTF_LITE_MCU_DEBUG_LOG
    NDEBUG
)

target_compile_options(microlite INTERFACE
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
    -Wno-error=sign-compare
    -fno-rtti
    -fno-exceptions
    -O3
    -Wno-error=maybe-uninitialized
)

target_link_libraries(usermod INTERFACE microlite)

