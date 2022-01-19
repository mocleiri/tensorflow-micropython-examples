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

if (PICO_SDK_PATH)
  set(MICROLITE_PLATFORM "RP2")
endif()

if(IDF_TARGET STREQUAL "esp32")
  set(MICROLITE_PLATFORM "ESP32")
  
endif()

if(IDF_TARGET STREQUAL "esp32s3")
  set(MICROLITE_PLATFORM "ESP32S3")
  
endif()


get_filename_component(TENSORFLOW_DIR ${PROJECT_DIR}/../../../tensorflow ABSOLUTE)

add_library(microlite INTERFACE)

if (MICROLITE_PLATFORM STREQUAL "ESP32" OR MICROLITE_PLATFORM STREQUAL "ESP32S3")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")


# list(APPEND COMPONENTS esp-nn)
# set (COMPONENTS esp-nn)

endif()

# needed when we have custom/specialized kernels.
# add_custom_command(
#     OUTPUT ${TF_MICROLITE_SPECIALIZED_SRCS}
#     COMMAND cd ${TENSORFLOW_DIR} && ${Python3_EXECUTABLE} ${MICROPY_DIR}/py/makeversionhdr.py ${MICROPY_MPVERSION}
#     DEPENDS MICROPY_FORCE_BUILD
# )

if (MICROLITE_PLATFORM STREQUAL "ESP32" OR MICROLITE_PLATFORM STREQUAL "ESP32S3")
    set (TF_MICROLITE_LOG 
        ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp
        ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp
    )

endif()

if (MICROLITE_PLATFORM STREQUAL "RP2")
    set (TF_MICROLITE_LOG 
        ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/cortex_m_generic/debug_log.cpp
        ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/cortex_m_generic/micro_time.cpp
    )
endif()




# copied from https://github.com/espressif/tflite-micro-esp-examples/blob/master/components/tflite-lib/CMakeLists.txt
# commit: 2ef35273160643b172ce76078c0c95c71d528842
set(TF_LITE_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite")
set(TF_MICRO_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro")

set(TF_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/schema/schema_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/log_scale_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/frontend_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/filterbank_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/log_scale.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/filterbank.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/window.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/kiss_fft_int16.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/window_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/noise_reduction_util.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/fft_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/noise_reduction.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/fft.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/experimental/microfrontend/lib/log_lut.c
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/kernels/internal/quantization_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/kernels/internal/reference/portable_tensor_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/kernels/kernel_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/flatbuffer_utils.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/recording_simple_memory_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_string.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_profiler.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/simple_memory_allocator.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/test_helpers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_resource_variable.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/dequantize.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/quantize.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/elu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/expand_dims.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/hard_swish.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/call_once.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/gather.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/comparisons.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/ceil.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/kernel_runner.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mul_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/gather_nd.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/maximum_minimum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logical_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logistic_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/transpose.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/split.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/zeros_like.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/if.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fill.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/floor_div.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/svdf_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cast.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pad.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/read_variable.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/sub_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/activations_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logistic.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mirror_pad.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/activations.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/slice.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/floor.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/strided_slice.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/circular_buffer.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/softmax.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/elementwise.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/unpack.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/space_to_depth.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/arg_min_max.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/round.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/leaky_relu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/split_v.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cumsum.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/prelu_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/circular_buffer_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/batch_to_space_nd.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/kernel_util.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/softmax_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/exp.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/var_handle.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mul.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/detection_postprocess.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/resize_nearest_neighbor.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/tanh.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depth_to_space.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/ethosu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/log_softmax.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add_n.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/neg.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/leaky_relu_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/shape.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pack.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/reshape.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/sub.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/space_to_batch_nd.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/floor_mod.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/squeeze.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/prelu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/hard_swish_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/svdf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/reduce.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2norm.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/concatenation.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/resize_bilinear.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/quantize_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/dequantize_common.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/logical.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/assign_variable.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/transpose_conv.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/recording_micro_allocator.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_interpreter.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_context.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_graph.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/all_ops_resolver.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_helpers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_error_reporter.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/mock_micro_graph.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_planner/linear_memory_planner.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/memory_planner/greedy_memory_planner.cpp
    # ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/fake_micro_context.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/system_setup.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/error_reporter.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/op_resolver.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/flatbuffer_conversions.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/core/api/tensor_utils.cpp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/c/common.c

)
# lite c 

file(GLOB TF_LITE_C_SRCS
          "${TF_LITE_DIR}/c/*.cpp"
          "${TF_LITE_DIR}/c/*.c")

# lite core/api 

file(GLOB TF_LITE_API_SRCS
          "${TF_LITE_DIR}/core/api/*.cpp"
          "${TF_LITE_DIR}/core/api/*.c")

# lite experimental 

file(GLOB TF_LITE_MICROFRONTEND_SRCS
          "${TF_LITE_DIR}/experimental/microfrontend/lib/*.c"
          "${TF_LITE_DIR}/experimental/microfrontend/lib/*.cpp")

# lite kernels 

file(GLOB TF_LITE_KERNELS_SRCS
          "${TF_LITE_DIR}/kernels/*.c"
          "${TF_LITE_DIR}/kernels/*.cpp"
          "${TF_LITE_DIR}/kernels/internal/*.c"
          "${TF_LITE_DIR}/kernels/internal/*.cpp"
          )

# lite schema 
file(GLOB TF_LITE_SCHEMA_SRCS
          "${TF_LITE_DIR}/schema/*.c"
          "${TF_LITE_DIR}/schema/*.cpp")

# micro 

file(GLOB TF_MICRO_SRCS
          "${TF_MICRO_DIR}/*.c"
          "${TF_MICRO_DIR}/*.cpp")

          
# logs are platform specific and added seperately

list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp)
list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp)

# micro kernels 

file(GLOB TF_MICRO_KERNELS_SRCS
          "${TF_MICRO_DIR}/kernels/*.c"
          "${TF_MICRO_DIR}/kernels/*.cpp")

# micro memory_planner 

file(GLOB TF_MICRO_MEMORY_PLANNER_SRCS
          "${TF_MICRO_DIR}/memory_planner/*.cpp"
          "${TF_MICRO_DIR}/memory_planner/*.c")

set (BOARD_ADDITIONAL_SRCS "")

if (MICROLITE_PLATFORM STREQUAL "RP2")

    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/softmax.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/svdf.cpp)
    
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/add.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/conv.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/depthwise_conv.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/fully_connected.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/mul.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/pooling.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/softmax.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/svdf.cpp)
    
    set (CMSIS_NN_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/BasicMathFunctions/arm_elementwise_mul_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/BasicMathFunctions/arm_elementwise_add_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ActivationFunctions/arm_nn_activations_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ActivationFunctions/arm_relu6_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ActivationFunctions/arm_relu_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ActivationFunctions/arm_relu_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ActivationFunctions/arm_nn_activations_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_q7_opt.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_mat_q7_vec_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_mat_q7_vec_q15_opt.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_q15_opt.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/FullyConnectedFunctions/arm_fully_connected_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_u8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_with_batch_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_avgpool_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_max_pool_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_pool_q7_HWC.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConcatenationFunctions/arm_concatenation_s8_z.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConcatenationFunctions/arm_concatenation_s8_w.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConcatenationFunctions/arm_concatenation_s8_x.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConcatenationFunctions/arm_concatenation_s8_y.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_conv_3x3_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_nn_depthwise_conv_s8_core.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_conv_wrapper_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_separable_conv_HWC_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q7_RGB.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_s8_s16_reordered.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_q7_q15_reordered.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_q7_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_separable_conv_HWC_q7_nonsquare.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_conv_s8_opt.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q15_basic.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_1x1_HWC_q7_fast_nonsquare.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_s8_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q7_fast_nonsquare.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_wrapper_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_conv_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q15_fast_nonsquare.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_1x1_s8_fast.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q7_basic.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_wrapper_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_fast_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_conv_u8_basic_ver1.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q15_fast.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q7_fast.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_nn_mat_mult_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_HWC_q7_basic_nonsquare.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_convolve_1_x_n_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_accumulate_q7_to_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_depthwise_conv_nt_t_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_q7_to_q15_no_shift.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_depthwise_conv_nt_t_padded_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_q7_to_q15_reordered_no_shift.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_mat_mul_core_1x_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_mat_mul_kernel_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nntables.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_vec_mat_mult_t_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_mat_mult_nt_t_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_add_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_q7_to_q15_reordered_with_offset.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_q7_to_q15_with_offset.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_mat_mul_core_4x_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_mult_q7.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_vec_mat_mult_t_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_vec_mat_mult_t_svdf_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/NNSupportFunctions/arm_nn_mult_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ReshapeFunctions/arm_reshape_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SVDFunctions/arm_svdf_s8.c
    )

target_sources(microlite INTERFACE
#   microlite micropython module sources
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/audio_frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/libtf-op-resolvers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp

    # tf lite sources
    # ${TF_LITE_C_SRCS}
    # ${TF_LITE_API_SRCS}
    # ${TF_LITE_MICROFRONTEND_SRCS}
    # ${TF_LITE_KERNELS_SRCS}
    # ${TF_LITE_SCHEMA_SRCS}

    # # tf micro sources
    # ${TF_MICRO_SRCS}
    # ${TF_MICRO_KERNELS_SRCS}
    # ${TF_MICRO_MEMORY_PLANNER_SRCS}

    ${TF_SOURCES}

    ${TF_MICROLITE_LOG}

    ${CMSIS_NN_SRCS}

    )

else()

# ESP32

    # set(BUGGY_OP ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp)

    # set_property(SOURCE ${BUGGY_OP} PROPERTY COMPILE_FLAGS -O3)

    # list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp)

    get_filename_component(ESP_NN_SRCS_DIR ${PROJECT_DIR}/../../../tflm_esp_kernels ABSOLUTE)

    if (MICROLITE_PLATFORM STREQUAL "ESP32S3")

    set(ESP_NN_SRCS
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s8_esp32s3.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_conv_esp32s3.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_conv_s16_mult8_1x1_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_conv_s16_mult4_1x1_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult4_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult1_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult8_3x3_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult1_3x3_no_pad_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s8_mult1_3x3_padded_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_conv_s16_mult8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult1_3x3_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/activation_functions/esp_nn_relu_s8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/pooling/esp_nn_max_pool_s8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/pooling/esp_nn_avg_pool_s8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/common/esp_nn_multiply_by_quantized_mult_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/common/esp_nn_common_functions_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/common/esp_nn_multiply_by_quantized_mult_ver1_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/basic_math/esp_nn_add_s8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/basic_math/esp_nn_mul_s8_esp32s3.S
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/fully_connected/esp_nn_fully_connected_s8_esp32s3.S
    )
    else()

    set(ESP_NN_SRCS
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_conv_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/convolution/esp_nn_depthwise_conv_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/activation_functions/esp_nn_relu_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/pooling/esp_nn_max_pool_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/pooling/esp_nn_avg_pool_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/basic_math/esp_nn_mul_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/basic_math/esp_nn_add_ansi.c
        ${ESP_NN_SRCS_DIR}/components/esp-nn/src/fully_connected/esp_nn_fully_connected_ansi.c

    )

    endif()

    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mul.cpp)
    list(REMOVE_ITEM TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling.cpp)
    
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/esp_nn/add.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/esp_nn/conv.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/esp_nn/depthwise_conv.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/esp_nn/fully_connected.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/esp_nn/mul.cpp)
    list(APPEND TF_SOURCES ${CMAKE_CURRENT_LIST_DIR}/esp_nn/pooling.cpp)


target_sources(microlite INTERFACE
#   microlite micropython module sources
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/audio_frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/libtf-op-resolvers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp

    # tf lite sources
    # ${TF_LITE_C_SRCS}
    # ${TF_LITE_API_SRCS}
    # ${TF_LITE_MICROFRONTEND_SRCS}
    # ${TF_LITE_KERNELS_SRCS}
    # ${TF_LITE_SCHEMA_SRCS}

    # # tf micro sources
    # ${TF_MICRO_SRCS}
    # ${TF_MICRO_KERNELS_SRCS}
    # ${TF_MICRO_MEMORY_PLANNER_SRCS}

    ${TF_SOURCES}

    ${TF_MICROLITE_LOG}

    ${ESP_NN_SRCS}

)

endif()



if (MICROLITE_PLATFORM STREQUAL "RP2")

target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/tflm
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft/tools
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/flatbuffers/include
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/gemmlowp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/ruy

    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/Core/Include
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Include
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/DSP/Include
)

target_compile_definitions(microlite INTERFACE
    MODULE_MICROLITE_ENABLED=1
    TF_LITE_STATIC_MEMORY=1
    TF_LITE_MCU_DEBUG_LOG
    NDEBUG
    CMSIS_NN
)

target_compile_options(microlite INTERFACE
    -Wno-error
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
    -Wno-error=sign-compare
    -fno-rtti
    -fno-exceptions
    -O2
    -Wno-error=maybe-uninitialized
)



else()

get_filename_component(ESP_NN ${PROJECT_DIR}/../../../tflm_esp_kernels/components/esp-nn ABSOLUTE)

# ESP32 
target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${ESP_NN}/include
    ${ESP_NN}/src/common
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
    TF_LITE_MCU_DEBUG_LOG
    NDEBUG
    ESP_NN
)

target_compile_options(microlite INTERFACE
    -Wno-error
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
    -Wno-error=sign-compare
    -Wno-error=unused-but-set-variable
    -fno-rtti
    -O3
    -fno-exceptions
    -Wno-error=maybe-uninitialized
)

endif()



target_link_libraries(usermod INTERFACE microlite)

