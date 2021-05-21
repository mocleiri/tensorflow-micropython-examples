#!/bin/bash

cd tensorflow

# These CFLAGS came from looking at what the Micropython c++ build was emitting.
make -f tensorflow/lite/micro/tools/make/Makefile \
CXXFLAGS="-std=c++11 -DNDEBUG -fstrict-volatile-bitfields -mlongcalls -nostdlib -fno-rtti -fno-exceptions -fno-threadsafe-statics -fno-unwind-tables -ffunction-sections -fdata-sections -fmessage-length=0 -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -O3 -Werror -Wsign-compare -Wdouble-promotion -Wshadow -Wunused-variable -Wmissing-field-initializers -Wunused-function -Wswitch -Wvla -Wall -Wextra -Wstrict-aliasing -Wno-unused-parameter -DESP -Wno-return-type -Wno-strict-aliasing -Wno-ignored-qualifiers -Wno-return-type  -Wno-strict-aliasing" \
TARGET_TOOLCHAIN_PREFIX=xtensa-esp32-elf- TARGET=esp TARGET_ARCH=xtensa-esp32 $@

#tensorflow/lite/micro/tools/make/gen/esp32_xtensawin/lib/libtensorflow-microlite.a
