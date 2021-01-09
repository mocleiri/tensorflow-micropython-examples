#!/bin/bash

cd tensorflow

# These CFLAGS came from looking at what the Micropython c++ build was emitting.
make -f tensorflow/lite/micro/tools/make/Makefile \
CXXFLAGS="-std=gnu++11 -Os -ffunction-sections -fdata-sections -fstrict-volatile-bitfields -mlongcalls -nostdlib -Wall -Werror -Wno-error=unused-function -Wno-error=unused-but-set-variable -Wno-error=unused-variable -Wno-error=deprecated-declarations -DESP_PLATFORM  -Wno-error=sign-compare -DMICROPY_ESP_IDF_4=1 -c -MD -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON" \
TARGET_TOOLCHAIN_PREFIX=xtensa-esp32-elf- TARGET=esp32 TARGET_ARCH=xtensa-esp32 $@

#tensorflow/lite/micro/tools/make/gen/esp32_xtensawin/lib/libtensorflow-microlite.a
