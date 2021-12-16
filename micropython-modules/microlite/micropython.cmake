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

# micro kernels 

file(GLOB TF_MICRO_KERNELS_SRCS
          "${TF_MICRO_DIR}/kernels/*.c"
          "${TF_MICRO_DIR}/kernels/*.cpp")

# micro memory_planner 

file(GLOB TF_MICRO_MEMORY_PLANNER_SRCS
          "${TF_MICRO_DIR}/memory_planner/*.cpp"
          "${TF_MICRO_DIR}/memory_planner/*.c")

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

target_link_libraries(usermod INTERFACE microlite)

