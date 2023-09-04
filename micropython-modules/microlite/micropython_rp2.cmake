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

if(NOT MICROPY_DIR)
    get_filename_component(MICROPY_DIR ${PROJECT_DIR}/../.. ABSOLUTE)
endif()

# `py.cmake` for `micropy_gather_target_properties` macro usage
include(${MICROPY_DIR}/py/py.cmake)

include (${CMAKE_CURRENT_LIST_DIR}/micropython_esp.cmake)

get_filename_component(TENSORFLOW_DIR ${PROJECT_DIR}/../../../tensorflow ABSOLUTE)

add_library(microlite INTERFACE)

# needed when we have custom/specialized kernels.
# add_custom_command(
#     OUTPUT ${TF_MICROLITE_SPECIALIZED_SRCS}
#     COMMAND cd ${TENSORFLOW_DIR} && ${Python3_EXECUTABLE} ${MICROPY_DIR}/py/makeversionhdr.py ${MICROPY_MPVERSION}
#     DEPENDS MICROPY_FORCE_BUILD
# )

if (MICROLITE_PLATFORM STREQUAL "RP2")
    set (TF_MICROLITE_LOG
        ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/cortex_m_generic/debug_log.cpp
        ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/cortex_m_generic/micro_time.cpp
    )
endif()

if (CONFIG_IDF_TARGET)
    set(TF_ESP_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tflm_esp_kernels/components/tflite-lib")
    set(TF_LITE_DIR "${TF_ESP_DIR}/tensorflow/lite")
    set(TF_MICRO_DIR "${TF_LITE_DIR}/micro")
    set(TF_MICROLITE_LOG
            ${TF_MICRO_DIR}/debug_log.cc
            ${TF_MICRO_DIR}/micro_time.cc
    )
else()
    set(TF_LITE_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite")
    set(TF_MICRO_DIR "${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro")
endif()

# lite c

file(GLOB TF_LITE_C_SRCS
          "${TF_LITE_DIR}/c/*.cpp"
          "${TF_LITE_DIR}/c/*.c")

# lite core/api
if (CONFIG_IDF_TARGET)
file(GLOB TF_LITE_API_SRCS
          "${TF_LITE_DIR}/core/api/*.cc"
          "${TF_LITE_DIR}/core/api/*.c"
          "${TF_LITE_DIR}/core/c/*.cc"
          "${TF_LITE_DIR}/core/c/*.c")
else()
file(GLOB TF_LITE_API_SRCS
          "${TF_LITE_DIR}/core/api/*.cpp"
          "${TF_LITE_DIR}/core/api/*.c")
endif()

# lite experimental

file(GLOB TF_LITE_MICROFRONTEND_SRCS
          "${TF_LITE_DIR}/experimental/microfrontend/lib/*.c"
          "${TF_LITE_DIR}/experimental/microfrontend/lib/*.cc"
          "${TF_LITE_DIR}/experimental/microfrontend/lib/*.cpp")

# lite kernels

file(GLOB TF_LITE_KERNELS_SRCS
          "${TF_LITE_DIR}/kernels/*.c"
          "${TF_LITE_DIR}/kernels/*.cpp"
          "${TF_LITE_DIR}/kernels/*.cc"
          "${TF_LITE_DIR}/kernels/internal/*.c"
          "${TF_LITE_DIR}/kernels/internal/*.cpp"
          "${TF_LITE_DIR}/kernels/internal/*.cc"
          "${TF_LITE_DIR}/kernels/internal/reference/*.c"
          "${TF_LITE_DIR}/kernels/internal/reference/*.cpp"
          "${TF_LITE_DIR}/kernels/internal/reference/*.cc"
          )

# lite schema
file(GLOB TF_LITE_SCHEMA_SRCS
          "${TF_LITE_DIR}/schema/*.c"
          "${TF_LITE_DIR}/schema/*.cc"
          "${TF_LITE_DIR}/schema/*.cpp")

# micro

file(GLOB TF_MICRO_SRCS
          "${TF_MICRO_DIR}/*.c"
          "${TF_MICRO_DIR}/*.cc"
          "${TF_MICRO_DIR}/*.cpp")


# logs are platform specific and added seperately

list(REMOVE_ITEM TF_MICRO_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/debug_log.cpp)
list(REMOVE_ITEM TF_MICRO_SRCS ${CMAKE_CURRENT_LIST_DIR}/tflm/tensorflow/lite/micro/micro_time.cpp)

# arena allocator
file(GLOB TF_MICRO_ARENA_ALLOCATOR_SRCS
          "${TF_MICRO_DIR}/arena_allocator/*.cpp"
          "${TF_MICRO_DIR}/arena_allocator/*.cc"
          "${TF_MICRO_DIR}/arena_allocator/*.c")

# micro kernels

file(GLOB TF_MICRO_KERNELS_SRCS
          "${TF_MICRO_DIR}/kernels/*.c"
          "${TF_MICRO_DIR}/kernels/*.cc"
          "${TF_MICRO_DIR}/kernels/*.cpp")

# micro memory_planner

file(GLOB TF_MICRO_MEMORY_PLANNER_SRCS
          "${TF_MICRO_DIR}/memory_planner/*.cpp"
          "${TF_MICRO_DIR}/memory_planner/*.cc"
          "${TF_MICRO_DIR}/memory_planner/*.c")

# tflite_bridge

file(GLOB TF_MICRO_TFLITE_BRIDGE_SRCS
          "${TF_MICRO_DIR}/tflite_bridge/*.cpp"
          "${TF_MICRO_DIR}/tflite_bridge/*.cc"
          "${TF_MICRO_DIR}/tflite_bridge/*.c")

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

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ActivationFunctions/arm_relu6_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ActivationFunctions/arm_relu_q15.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ActivationFunctions/arm_relu_q7.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/BasicMathFunctions/arm_elementwise_add_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/BasicMathFunctions/arm_elementwise_add_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/BasicMathFunctions/arm_elementwise_mul_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/BasicMathFunctions/arm_elementwise_mul_s8.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConcatenationFunctions/arm_concatenation_s8_w.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConcatenationFunctions/arm_concatenation_s8_x.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConcatenationFunctions/arm_concatenation_s8_y.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConcatenationFunctions/arm_concatenation_s8_z.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_1x1_s8_fast.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_1_x_n_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_fast_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_wrapper_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_convolve_wrapper_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_3x3_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_fast_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_s8_opt.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_wrapper_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_depthwise_conv_wrapper_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_nn_depthwise_conv_s8_core.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_nn_mat_mult_kernel_s8_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ConvolutionFunctions/arm_nn_mat_mult_s8.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/FullyConnectedFunctions/arm_fully_connected_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/FullyConnectedFunctions/arm_fully_connected_s8.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_depthwise_conv_nt_t_padded_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_depthwise_conv_nt_t_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_depthwise_conv_nt_t_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_mat_mul_core_1x_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_mat_mul_core_4x_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_mat_mul_kernel_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_mat_mult_nt_t_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nntables.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_vec_mat_mult_t_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_vec_mat_mult_t_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_nn_vec_mat_mult_t_svdf_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/NNSupportFunctions/arm_q7_to_q15_with_offset.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/PoolingFunctions/arm_avgpool_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/PoolingFunctions/arm_avgpool_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/PoolingFunctions/arm_max_pool_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/PoolingFunctions/arm_max_pool_s8.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/ReshapeFunctions/arm_reshape_s8.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SoftmaxFunctions/arm_nn_softmax_common_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SoftmaxFunctions/arm_softmax_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SoftmaxFunctions/arm_softmax_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SoftmaxFunctions/arm_softmax_s8_s16.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SoftmaxFunctions/arm_softmax_u8.c

        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SVDFunctions
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SVDFunctions/arm_svdf_s8.c
        ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Source/SVDFunctions/arm_svdf_state_s16_s8.c

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
    ${TF_MICRO_TFLITE_BRIDGE_SRCS}

    ${TF_MICROLITE_LOG}

    ${CMSIS_NN_SRCS}

    )

else()

if (CONFIG_IDF_TARGET)
    set(tfmicro_kernels_dir ${TF_MICRO_DIR}/kernels)
    # set(tfmicro_nn_kernels_dir
    #     ${tfmicro_kernels_dir}/)

    # remove sources which will be provided by esp_nn
    list(REMOVE_ITEM TF_MICRO_KERNELS_SRCS
        "${tfmicro_kernels_dir}/add.cc"
        "${tfmicro_kernels_dir}/conv.cc"
        "${tfmicro_kernels_dir}/depthwise_conv.cc"
        "${tfmicro_kernels_dir}/fully_connected.cc"
        "${tfmicro_kernels_dir}/mul.cc"
        "${tfmicro_kernels_dir}/pooling.cc"
        "${tfmicro_kernels_dir}/softmax.cc"
    )

    # tflm wrappers for ESP_NN
    FILE(GLOB ESP_NN_WRAPPERS
        "${tfmicro_kernels_dir}/esp_nn/*.cc")
endif()

#   microlite micropython module sources
set (MICROLITE_PYTHON_SRCS
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/audio_frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp
)

if (CONFIG_IDF_TARGET)
    list(APPEND MICROLITE_PYTHON_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf-updated.cpp
    )
else()
    list(APPEND MICROLITE_PYTHON_SRCS
        ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    )
endif()

target_sources(microlite INTERFACE
    # micro_python sources for tflite
    ${MICROLITE_PYTHON_SRCS}

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
    ${TF_MICRO_TFLITE_BRIDGE_SRCS}

    ${TF_MICROLITE_LOG}
    ${ESP_NN_SRCS} # include esp-nn sources for Espressif chipsets
    ${ESP_NN_WRAPPERS} # add tflm wrappers for ESP_NN
    )

if (CONFIG_IDF_TARGET)
    set(signal_srcs
        ${TF_ESP_DIR}/signal/micro/kernels/rfft.cc
        ${TF_ESP_DIR}/signal/micro/kernels/window.cc
        ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers/kiss_fft_float.cc
        ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers/kiss_fft_int16.cc
        ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers/kiss_fft_int32.cc
        ${TF_ESP_DIR}/signal/src/rfft_float.cc
        ${TF_ESP_DIR}/signal/src/rfft_int16.cc
        ${TF_ESP_DIR}/signal/src/rfft_int32.cc
        ${TF_ESP_DIR}/signal/src/window.cc
    )
    target_sources(microlite INTERFACE
        ${CMAKE_CURRENT_LIST_DIR}/python_ops_resolver.cc
        ${signal_srcs}
    )
endif()

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
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/cmsis_nn/Include
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

else() # not "RP2"
if (CONFIG_IDF_TARGET)
target_include_directories(microlite INTERFACE
    ${TF_ESP_DIR}
    ${TF_ESP_DIR}/third_party/kissfft
    ${TF_ESP_DIR}/third_party/kissfft/tools
    ${TF_ESP_DIR}/third_party/flatbuffers/include
    ${TF_ESP_DIR}/third_party/gemmlowp
    ${TF_ESP_DIR}/third_party/ruy
    ${TF_ESP_DIR}/signal/micro/kernels
    ${TF_ESP_DIR}/signal/src
    ${TF_ESP_DIR}/signal/src/kiss_fft_wrappers
    ${ESP_NN_INC}
)
else()

target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/tflm
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/kissfft/tools
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/flatbuffers/include
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/gemmlowp
    ${CMAKE_CURRENT_LIST_DIR}/tflm/third_party/ruy
)
endif()

target_compile_definitions(microlite INTERFACE
    MODULE_MICROLITE_ENABLED=1
    TF_LITE_STATIC_MEMORY=1
    TF_LITE_MCU_DEBUG_LOG
    NDEBUG
    )
if (CONFIG_IDF_TARGET)
    target_compile_definitions(microlite INTERFACE
        ESP_NN=1 # enables esp_nn optimizations if those sources are added
        CONFIG_NN_OPTIMIZED=1 # use Optimized vs ansi code from ESP-NN
    )
endif()

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

if (CONFIG_IDF_TARGET_ESP32S3) # Extra compile options needed to build esp-nn ASM for ESP32-S3
    target_compile_options(microlite INTERFACE -mlongcalls -fno-unroll-loops -Wno-unused-function)
endif()
endif()

target_link_libraries(usermod INTERFACE microlite)
micropy_gather_target_properties(microlite)
