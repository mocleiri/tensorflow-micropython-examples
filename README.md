# Tensorflow Lite for Microcontrollers in Micropython

The purpose of this project is to make a custom micropython firmware that installs tensorflow lite for micro controllers and allows for experimentation.

# Status

Tensorflow for ESP32 can be built and accessed by the microlite c/c++ module.  Inference is not yet working.

I have ESP32 boards but it should work for other ports as well.

# Roadmap

First we need to get the hello world example running.  Then we need to investigate how to externalize the provisioning of:
1. Model file
2. Setup data on the input tensor.
3. Extract data from output tensor.

I want to come up with a way where native modules can be used to provide these details and then the base firmware contains the tensorflow-microlite.a library and some micropython module plumbing but the model details come in externally.

If this works then we can look at using a similiar approach to externalize the Op's which would then allow shrinking the firmware and putting those items on the file system.

## Implement 'hello-world' example

At the moment things are hard coded but not working.

## Implement 'micro-speech' example

This firmware is based on https://github.com/miketeachman/micropython/tree/esp32-i2s which adds an i2s module which is needed for sampling audio for this example.

Plan to copy the openmv py_micro_speech.c file which converts the audio sample into the correct input tensor values.


# How to Build Tensorflow

```
make -f tensorflow/lite/micro/tools/make/Makefile  TARGET=esp32  TOOLCHAIN=xtensa-esp32-elf-gcc CXX
_TOOL=xtensa-esp32-elf-g++  CC_TOOL=xtensa-esp32-elf-gcc AR_TOOL=xtensa-esp32-elf-ar

```
 
# How to Build Micropython

```
make -f /src/src/GNUmakefile V=1 PART_SRC=/src/custom-partitions.csv MICROPY_PY_BLUETOOTH=0 M
ICROPY_BLUETOOTH_NIMBLE=0 MICROPY_BLUETOOTH_NIMBLE_BINDINGS_ONLY=0 CONFIG_ESP32_SPIRAM_SUPPORT=n all
```
# Flash image

ESP32D0WDQ6 4MB Flash

```

esptool.py --port COM5 erase_flash
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash -z 0x1000 esp32-20180511-v1.9.4.bin
```

[images/write-firmware]

# Credits

This firmware copied extensively from OpenMV.  Specifically starting from  


https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.cc
and
https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.h

https://github.com/openmv/openmv/blob/3d9929eeae563c5b370ac86afa9216df50f0c079/src/omv/ports/stm32/modules/py_micro_speech.c
