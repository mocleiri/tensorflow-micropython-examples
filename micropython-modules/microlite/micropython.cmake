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

add_library(tensorflow STATIC IMPORTED)

SET_TARGET_PROPERTIES(tensorflow PROPERTIES
    IMPORTED_LOCATION /opt/tflite-micro-micropython/lib/libtensorflow-microlite.a)

target_link_libraries(microlite INTERFACE tensorflow)


target_sources(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c

    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/libtf-op-resolvers.cpp
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp
)

target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${TENSORFLOW_DIR}
    ${TENSORFLOW_DIR}/tensorflow/lite/micro/tools/make/downloads/flatbuffers/include
)

target_compile_definitions(microlite INTERFACE
    MODULE_MICROLITE_ENABLED=1
    TF_LITE_STATIC_MEMORY=1
)

target_compile_options(microlite INTERFACE
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
    -Wno-error=sign-compare
)

target_link_libraries(usermod INTERFACE microlite)

