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

add_library(microlite INTERFACE)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")



target_sources(microlite INTERFACE
#   microlite micropython module sources
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/audio_frontend.c
    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/python_ops_resolver.cc
)

get_filename_component(TENSORFLOW_DIR ${CMAKE_CURRENT_LIST_DIR}/../../dependencies/tflite-micro-esp-examples/components/esp-tflite-micro ABSOLUTE)
get_filename_component(TENSORFLOW_THIRD_PARTY_DIR ${CMAKE_CURRENT_LIST_DIR}/../../dependencies/tflite-micro-esp-examples/components/esp-tflite-micro/third_party ABSOLUTE)

set (FLATBUFFERS_DIR ${TENSORFLOW_THIRD_PARTY_DIR}/flatbuffers/include)
set (GEMMLOWP_DIR ${TENSORFLOW_THIRD_PARTY_DIR}/gemmlowp)
set (KISSFFT_DIR ${TENSORFLOW_THIRD_PARTY_DIR}/kissfft)
set (RUY_DIR ${TENSORFLOW_THIRD_PARTY_DIR}/ruy)

# ESP32 
target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${TENSORFLOW_DIR}
    ${FLATBUFFERS_DIR}
    ${GEMMLOWP_DIR}
    ${KISSFFT_DIR}
    ${RUY_DIR}
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
    -Wno-error=stringop-overflow
    -fno-exceptions
    -O3
    -Wno-error=maybe-uninitialized
)


target_link_libraries(usermod INTERFACE microlite)

