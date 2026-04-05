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

list(APPEND IDF_COMPONENTS espressif__esp-tflite-micro)

get_filename_component(TFLM_ESP_KERNELS_DIR ${CMAKE_CURRENT_LIST_DIR}/../../tflm_esp_kernels ABSOLUTE)
get_filename_component(TFLM_ESP_EXAMPLE_DIR ${TFLM_ESP_KERNELS_DIR}/examples/micro_speech/main ABSOLUTE)

set(microlite_module_srcs
    ${CMAKE_CURRENT_LIST_DIR}/tensorflow-microlite.c
    ${CMAKE_CURRENT_LIST_DIR}/audio_frontend_esp.cpp
    ${CMAKE_CURRENT_LIST_DIR}/openmv-libtf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/micropython-error-reporter.cpp)

target_sources(microlite INTERFACE ${microlite_module_srcs})

target_include_directories(microlite INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${TFLM_ESP_EXAMPLE_DIR})

set(microlite_common_compile_options
    -O3
    -Wno-error
    -Wno-error=float-conversion
    -Wno-error=nonnull
    -Wno-error=double-promotion
    -Wno-error=pointer-arith
    -Wno-error=unused-const-variable
    -Wno-error=sign-compare
    -Wno-error=maybe-uninitialized
    -Wno-error=attributes
    -Wno-error=shadow
    -Wno-maybe-uninitialized
    -Wno-missing-field-initializers
    -Wno-type-limits
    -Wno-unused-parameter
    -Wno-nonnull
    -ffunction-sections
    -fdata-sections)

set(microlite_cxx_compile_options
    -std=gnu++11
    -fno-rtti
    -fno-exceptions)

foreach(src IN LISTS microlite_module_srcs)
    set_property(SOURCE ${src} APPEND PROPERTY COMPILE_DEFINITIONS
        TF_LITE_STATIC_MEMORY=1
        TF_LITE_DISABLE_X86_NEON
        TF_LITE_MCU_DEBUG_LOG
        NDEBUG)
    set_property(SOURCE ${src} APPEND PROPERTY COMPILE_OPTIONS ${microlite_common_compile_options})
endforeach()

foreach(src IN LISTS microlite_module_srcs)
    if (src MATCHES "\\.(cc|cpp)$")
        set_property(SOURCE ${src} APPEND PROPERTY COMPILE_OPTIONS ${microlite_cxx_compile_options})
    endif()
endforeach()

target_link_libraries(usermod INTERFACE microlite)
