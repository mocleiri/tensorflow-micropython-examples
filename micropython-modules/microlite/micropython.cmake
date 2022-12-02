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

list(REMOVE_ITEM TF_MICRO_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp)
list(REMOVE_ITEM TF_MICRO_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp)

# arena allocator
file(GLOB TF_MICRO_ARENA_ALLOCATOR_SRCS
          "${TF_MICRO_DIR}/arena_allocator/*.cpp"
          "${TF_MICRO_DIR}/arena_allocator/*.c")

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

    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/add.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/conv.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/depthwise_conv.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/fully_connected.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/mul.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/pooling.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/softmax.cpp)
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/svdf.cpp)
    
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/add.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/conv.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/depthwise_conv.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/fully_connected.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/mul.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/pooling.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/softmax.cpp)
    list(APPEND TF_MICRO_KERNELS_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/kernels/cmsis_nn/svdf.cpp)
    
    set (CMSIS_NN_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/BasicMathFunctions/arm_elementwise_mul_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/BasicMathFunctions/arm_elementwise_mul_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/BasicMathFunctions/arm_elementwise_add_s16.c
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
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_s8_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_nn_softmax_common_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SoftmaxFunctions/arm_softmax_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_max_pool_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_avgpool_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_max_pool_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_pool_q7_HWC.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/PoolingFunctions/arm_avgpool_s16.c
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
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/ConvolutionFunctions/arm_depthwise_conv_s16.c
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
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis/CMSIS/NN/Source/SVDFunctions/arm_svdf_state_s16_s8.c
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
    ${TF_MICRO_ARENA_ALLOCATOR_SRCS}
    ${TF_MICRO_KERNELS_SRCS}
    ${TF_MICRO_MEMORY_PLANNER_SRCS}

    ${TF_MICROLITE_LOG}

    ${CMSIS_NN_SRCS}

    )

else()


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
    ${TF_MICRO_ARENA_ALLOCATOR_SRCS}
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
    ARMCM0=1
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

# ESP32 
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
    TF_LITE_MCU_DEBUG_LOG
    NDEBUG
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
    -O3
    -Wno-error=maybe-uninitialized
)

endif()



target_link_libraries(usermod INTERFACE microlite)

