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

add_library(audio_frontend INTERFACE)

# file(GLOB_RECURSE ULAB_SOURCES ${CMAKE_CURRENT_LIST_DIR}/*.c)

target_sources(audio_frontend INTERFACE
   ${TENSORFLOW_DIR}/tensorflow/lite/micro/tools/make/downloads/kissfft/kiss_fft.c
   ${TENSORFLOW_DIR}/tensorflow/lite/micro/tools/make/downloads/kissfft/tools/kiss_fftr.c

   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/filterbank.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/filterbank_util.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/frontend.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/frontend_util.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/log_lut.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/log_scale.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/log_scale_util.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/noise_reduction.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/noise_reduction_util.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/pcan_gain_control_util.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/window.c
   ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib/window_util.c

   ${CMAKE_CURRENT_LIST_DIR}/audio_frontend_module.c

   ${CMAKE_CURRENT_LIST_DIR}/fft.cpp
   ${CMAKE_CURRENT_LIST_DIR}/fft_util.cpp

)

target_include_directories(audio_frontend INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${TENSORFLOW_DIR}
    ${TENSORFLOW_DIR}/tensorflow/lite/micro/tools/make/downloads/kissfft
    ${TENSORFLOW_DIR}/tensorflow/lite/experimental/microfrontend/lib
)

target_compile_definitions(audio_frontend INTERFACE
    MODULE_AUDIO_FRONTEND_ENABLED=1
    TF_LITE_STATIC_MEMORY=1
)

target_compile_options(audio_frontend INTERFACE
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
)

target_link_libraries(usermod INTERFACE audio_frontend)

