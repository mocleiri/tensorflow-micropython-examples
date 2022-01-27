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


list (APPEND COMPONENTS esp-nn)

endif()

# copied from https://github.com/espressif/tflite-micro-esp-examples/blob/master/components/tflite-lib/CMakeLists.txt
# commit: 2ef35273160643b172ce76078c0c95c71d528842
set(TF_LITE_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite")
set(TF_MICRO_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro")

if (MICROLITE_PLATFORM STREQUAL "ESP32" OR MICROLITE_PLATFORM STREQUAL "ESP32S3")
    set (TF_MICROLITE_LOG 
        ${TF_MICRO_DIR}/debug_log.cpp
        ${TF_MICRO_DIR}/micro_time.cpp
    )

endif()

if (MICROLITE_PLATFORM STREQUAL "RP2")
    set (TF_MICROLITE_LOG 
        ${TF_MICRO_DIR}/cortex_m_generic/debug_log.cpp
        ${TF_MICRO_DIR}/cortex_m_generic/micro_time.cpp
    )
endif()

# lite c 

set(TF_LITE_C_SRCS
    ${TF_LITE_DIR}/c/common.c)

# lite core/api 

set(TF_LITE_API_SRCS
          ${TF_LITE_DIR}/core/api/error_reporter.cpp
          ${TF_LITE_DIR}/core/api/op_resolver.cpp
          ${TF_LITE_DIR}/core/api/flatbuffer_conversions.cpp
          ${TF_LITE_DIR}/core/api/tensor_utils.cpp
          )

# lite experimental 

set(TF_LITE_MICROFRONTEND_SRCS
    ${TF_LITE_DIR}/experimental/microfrontend/lib/log_scale_util.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/frontend_util.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/pcan_gain_control.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/filterbank_util.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/log_scale.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/filterbank.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/window.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/kiss_fft_int16.cpp
    ${TF_LITE_DIR}/experimental/microfrontend/lib/window_util.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/pcan_gain_control_util.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/frontend.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/noise_reduction_util.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/fft_util.cpp
    ${TF_LITE_DIR}/experimental/microfrontend/lib/noise_reduction.c
    ${TF_LITE_DIR}/experimental/microfrontend/lib/fft.cpp
    ${TF_LITE_DIR}/experimental/microfrontend/lib/log_lut.c
)

# lite kernels 

set(TF_LITE_KERNELS_SRCS
    ${TF_LITE_DIR}/kernels/internal/quantization_util.cpp
    ${TF_LITE_DIR}/kernels/internal/reference/portable_tensor_utils.cpp
    ${TF_LITE_DIR}/kernels/kernel_util.cpp
)

# lite schema 
set(TF_LITE_SCHEMA_SRCS
    ${TF_LITE_DIR}/schema/schema_utils.cpp          
)

# micro 

# extra srcs not needed in normal build
set(TF_MICRO_EXTRA_SRCS
    ${TF_MICRO_DIR}/recording_simple_memory_allocator.cpp
    ${TF_MICRO_DIR}/micro_profiler.cpp
    ${TF_MICRO_DIR}/test_helpers.cpp
    ${TF_MICRO_DIR}/recording_micro_allocator.cpp
    ${TF_MICRO_DIR}/mock_micro_graph.cpp
    ${TF_MICRO_DIR}/fake_micro_context.cpp
)

set(TF_MICRO_SRCS
    ${TF_MICRO_DIR}/micro_utils.cpp
    ${TF_MICRO_DIR}/flatbuffer_utils.cpp
    ${TF_MICRO_DIR}/micro_string.cpp
    ${TF_MICRO_DIR}/micro_allocator.cpp
    ${TF_MICRO_DIR}/simple_memory_allocator.cpp
    ${TF_MICRO_DIR}/micro_resource_variable.cpp
    ${TF_MICRO_DIR}/micro_interpreter.cpp
    ${TF_MICRO_DIR}/micro_context.cpp
    ${TF_MICRO_DIR}/debug_log.cpp
    ${TF_MICRO_DIR}/micro_graph.cpp
    ${TF_MICRO_DIR}/micro_time.cpp
    ${TF_MICRO_DIR}/all_ops_resolver.cpp
    ${TF_MICRO_DIR}/memory_helpers.cpp
    ${TF_MICRO_DIR}/micro_error_reporter.cpp
    ${TF_MICRO_DIR}/system_setup.cpp 
)

          
# logs are platform specific and added seperately

list(REMOVE_ITEM TF_MICRO_SRCS ${TF_MICRO_DIR}/debug_log.cpp)
list(REMOVE_ITEM TF_MICRO_SRCS ${TF_MICRO_DIR}/micro_time.cpp)

# micro kernels 

set(TF_MICRO_KERNELS_SRCS
    ${TF_MICRO_DIR}/kernels/dequantize.cpp
    ${TF_MICRO_DIR}/kernels/quantize.cpp
    ${TF_MICRO_DIR}/kernels/elu.cpp
    ${TF_MICRO_DIR}/kernels/pooling_common.cpp
    ${TF_MICRO_DIR}/kernels/expand_dims.cpp
    ${TF_MICRO_DIR}/kernels/hard_swish.cpp
    ${TF_MICRO_DIR}/kernels/conv_common.cpp
    ${TF_MICRO_DIR}/kernels/call_once.cpp
    ${TF_MICRO_DIR}/kernels/gather.cpp
    ${TF_MICRO_DIR}/kernels/comparisons.cpp
    ${TF_MICRO_DIR}/kernels/ceil.cpp
    ${TF_MICRO_DIR}/kernels/kernel_runner.cpp
    ${TF_MICRO_DIR}/kernels/mul_common.cpp
    ${TF_MICRO_DIR}/kernels/gather_nd.cpp
    ${TF_MICRO_DIR}/kernels/maximum_minimum.cpp
    ${TF_MICRO_DIR}/kernels/fully_connected.cpp
    ${TF_MICRO_DIR}/kernels/logical_common.cpp
    ${TF_MICRO_DIR}/kernels/pooling.cpp
    ${TF_MICRO_DIR}/kernels/depthwise_conv_common.cpp
    ${TF_MICRO_DIR}/kernels/logistic_common.cpp
    ${TF_MICRO_DIR}/kernels/transpose.cpp
    ${TF_MICRO_DIR}/kernels/split.cpp
    ${TF_MICRO_DIR}/kernels/zeros_like.cpp
    ${TF_MICRO_DIR}/kernels/if.cpp
    ${TF_MICRO_DIR}/kernels/fill.cpp
    ${TF_MICRO_DIR}/kernels/floor_div.cpp
    ${TF_MICRO_DIR}/kernels/svdf_common.cpp
    ${TF_MICRO_DIR}/kernels/cast.cpp
    ${TF_MICRO_DIR}/kernels/pad.cpp
    ${TF_MICRO_DIR}/kernels/read_variable.cpp
    ${TF_MICRO_DIR}/kernels/sub_common.cpp
    ${TF_MICRO_DIR}/kernels/activations_common.cpp
    ${TF_MICRO_DIR}/kernels/logistic.cpp
    ${TF_MICRO_DIR}/kernels/mirror_pad.cpp
    ${TF_MICRO_DIR}/kernels/activations.cpp
    ${TF_MICRO_DIR}/kernels/slice.cpp
    ${TF_MICRO_DIR}/kernels/floor.cpp
    ${TF_MICRO_DIR}/kernels/strided_slice.cpp
    ${TF_MICRO_DIR}/kernels/circular_buffer.cpp
    ${TF_MICRO_DIR}/kernels/softmax.cpp
    ${TF_MICRO_DIR}/kernels/elementwise.cpp
    ${TF_MICRO_DIR}/kernels/unpack.cpp
    ${TF_MICRO_DIR}/kernels/space_to_depth.cpp
    ${TF_MICRO_DIR}/kernels/arg_min_max.cpp
    ${TF_MICRO_DIR}/kernels/round.cpp
    ${TF_MICRO_DIR}/kernels/depthwise_conv.cpp
    ${TF_MICRO_DIR}/kernels/leaky_relu.cpp
    ${TF_MICRO_DIR}/kernels/conv.cpp
    ${TF_MICRO_DIR}/kernels/split_v.cpp
    ${TF_MICRO_DIR}/kernels/cumsum.cpp
    ${TF_MICRO_DIR}/kernels/prelu_common.cpp
    ${TF_MICRO_DIR}/kernels/circular_buffer_common.cpp
    ${TF_MICRO_DIR}/kernels/batch_to_space_nd.cpp
    ${TF_MICRO_DIR}/kernels/kernel_util.cpp
    ${TF_MICRO_DIR}/kernels/softmax_common.cpp
    ${TF_MICRO_DIR}/kernels/exp.cpp
    ${TF_MICRO_DIR}/kernels/var_handle.cpp
    ${TF_MICRO_DIR}/kernels/mul.cpp
    ${TF_MICRO_DIR}/kernels/detection_postprocess.cpp
    ${TF_MICRO_DIR}/kernels/resize_nearest_neighbor.cpp
    ${TF_MICRO_DIR}/kernels/tanh.cpp
    ${TF_MICRO_DIR}/kernels/add.cpp
    ${TF_MICRO_DIR}/kernels/depth_to_space.cpp
    ${TF_MICRO_DIR}/kernels/ethosu.cpp
    ${TF_MICRO_DIR}/kernels/log_softmax.cpp
    ${TF_MICRO_DIR}/kernels/add_n.cpp
    ${TF_MICRO_DIR}/kernels/neg.cpp
    ${TF_MICRO_DIR}/kernels/add_common.cpp
    ${TF_MICRO_DIR}/kernels/leaky_relu_common.cpp
    ${TF_MICRO_DIR}/kernels/shape.cpp
    ${TF_MICRO_DIR}/kernels/pack.cpp
    ${TF_MICRO_DIR}/kernels/reshape.cpp
    ${TF_MICRO_DIR}/kernels/sub.cpp
    ${TF_MICRO_DIR}/kernels/space_to_batch_nd.cpp
    ${TF_MICRO_DIR}/kernels/floor_mod.cpp
    ${TF_MICRO_DIR}/kernels/squeeze.cpp
    ${TF_MICRO_DIR}/kernels/prelu.cpp
    ${TF_MICRO_DIR}/kernels/hard_swish_common.cpp
    ${TF_MICRO_DIR}/kernels/svdf.cpp
    ${TF_MICRO_DIR}/kernels/l2_pool_2d.cpp
    ${TF_MICRO_DIR}/kernels/reduce.cpp
    ${TF_MICRO_DIR}/kernels/l2norm.cpp
    ${TF_MICRO_DIR}/kernels/concatenation.cpp
    ${TF_MICRO_DIR}/kernels/resize_bilinear.cpp
    ${TF_MICRO_DIR}/kernels/quantize_common.cpp
    ${TF_MICRO_DIR}/kernels/fully_connected_common.cpp
    ${TF_MICRO_DIR}/kernels/dequantize_common.cpp
    ${TF_MICRO_DIR}/kernels/logical.cpp
    ${TF_MICRO_DIR}/kernels/assign_variable.cpp
    ${TF_MICRO_DIR}/kernels/transpose_conv.cpp          
)

# micro memory_planner 

set(TF_MICRO_MEMORY_PLANNER_SRCS
    ${TF_MICRO_DIR}/memory_planner/linear_memory_planner.cpp
    ${TF_MICRO_DIR}/memory_planner/non_persistent_buffer_planner_shim.cpp
    ${TF_MICRO_DIR}/memory_planner/greedy_memory_planner.cpp
)

set (BOARD_ADDITIONAL_SRCS "")

if (MICROLITE_PLATFORM STREQUAL "RP2")

    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/add.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/conv.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/depthwise_conv.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/fully_connected.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/mul.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/pooling.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/softmax.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/svdf.cpp)
    
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/add.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/conv.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/depthwise_conv.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/fully_connected.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/mul.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/pooling.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/softmax.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/cmsis_nn/svdf.cpp)
    
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
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp

    # tf lite sources
    ${TF_LITE_C_SRCS}
    ${TF_LITE_API_SRCS}
    ${TF_LITE_MICROFRONTEND_SRCS}
    ${TF_LITE_KERNELS_SRCS}
    ${TF_LITE_SCHEMA_SRCS}

    # tf micro sources
    ${TF_MICRO_SRCS}
    ${TF_MICRO_KERNELS_SRCS}
    ${TF_MICRO_MEMORY_PLANNER_SRCS}

    ${TF_MICROLITE_LOG}

    ${CMSIS_NN_SRCS}

    )

else()

# ESP32

    # set(BUGGY_OP ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp)

    # set_property(SOURCE ${BUGGY_OP} PROPERTY COMPILE_FLAGS -O3)

    # list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/l2_pool_2d.cpp)

    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/add.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/conv.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/depthwise_conv.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/fully_connected.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/mul.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${TF_MICRO_DIR}/kernels/pooling.cpp)
    
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/esp_nn/add.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/esp_nn/conv.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/esp_nn/depthwise_conv.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/esp_nn/fully_connected.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/esp_nn/mul.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/esp_nn/pooling.cpp)


target_sources(microlite INTERFACE
#   microlite micropython module sources
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/audio_frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp

    # tf lite sources
    ${TF_LITE_C_SRCS}
    ${TF_LITE_API_SRCS}
    ${TF_LITE_MICROFRONTEND_SRCS}
    ${TF_LITE_KERNELS_SRCS}
    ${TF_LITE_SCHEMA_SRCS}

    # tf micro sources
    ${TF_MICRO_SRCS}
    ${TF_MICRO_KERNELS_SRCS}
    ${TF_MICRO_MEMORY_PLANNER_SRCS}

    ${TF_MICROLITE_LOG}

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
    -fno-rtti
    -O3
    -fno-exceptions
    -Wno-error=maybe-uninitialized
)

endif()



target_link_libraries(usermod INTERFACE microlite)

