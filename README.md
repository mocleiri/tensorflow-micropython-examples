# Tensorflow Lite for Microcontrollers in Micropython

The purpose of this project is to make a custom micropython firmware that installs tensorflow lite for micro controllers and allows for experimentation.

I want to incubate this project here but if it is successful at enabling tensorflow lite for microcontroller models to be run from micropython I will explore how to merge the microlite and audio_frontend modules into the tensorflow for microcontrollers upstream repository.

## Architecture

| Area        | Are           | 
| ------------- |:-------------:| 
| tensorflow-microlite.a | This is the tensorflow lite library with all operations to start with |
| micropython-modules/microlite | Micropython 'microlite' module that interconnects micropython to tensorflow lite |
| micropython-modules/audio_frontend | Wrapper for tensorflow experimental microfrontend audio processor needed by the micro_speech example to convert wav data into spectrogram data for processing by the model. |
| micropython-modules/ulab | We have a submodule dependency on [ulab](https://github.com/v923z/micropython-ulab).  |

At the moment all of the tensor operations are included in tensorflow-microlite.a but in the future we will try to externalize them so they can be brought on the file system with the model being run.


# Status

Build Type | Status |
 --------- | ------ |
ESP32   | [![ESP32](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_esp32.yml) |
UNIX   | [![UNIX](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_unix.yml/badge.svg)](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_unix.yml) |


The latest firmware can be downloaded from the applicable build above.
1. Click on build status link.
2. Click on the latest green build
3. Review the available artifiacts for download

You do need to be careful to get the proper firmware for your board.  If your board is not currently being built please file an issue and it can be added.

## Download Build Artifact Example

![](./images/download-esp32-artifact.png)


# Prebuilt Firmware

Once we get to version 1.0.0 there will be release firmware.  At the moment the best option is to get the firmware built as part of the ci run above.

# Roadmap

Inference is working for the hello-world sine example and mostly for the micro_speech example.

1. Cleanup micro_speech implementation: https://github.com/mocleiri/tensorflow-micropython-examples/issues/2
2. Implement the magic wand example: https://github.com/mocleiri/tensorflow-micropython-examples/issues/5
3. Investigate automatic tensor quantization: https://github.com/mocleiri/tensorflow-micropython-examples/issues/6
4. Find way to externalize tensor op's from firmware:https://github.com/mocleiri/tensorflow-micropython-examples/issues/7

## Implement 'micro-speech' example


This firmware is based on https://github.com/miketeachman/micropython/tree/esp32-i2s which adds an i2s module which is needed for sampling audio for this example.

Plan to copy the openmv py_micro_speech.c file which converts the audio sample into the correct input tensor values.

# About Tensorflow

At the moment we are using the r2.4 branch in tensorflow and then using the user implementation Makefile to build the full tensorflow lite for microcontroller library.

Later we will try to move the ops out into something that can be wrapped as a native micropython module and added via being on the file system.

# About Micropython

For the micros-speech example we are using a custom version of micropython with miketeachman's i2s module added for esp32 plus a few other changes related to getting the build to work right.

Probably if you don't need that then you could build from either the last release or master instead.

# How to Build

Normally you can just download the precompiled firmware.  If you want to know how to build it yourself
then consult the [Build Documentation](BUILD.md).

# Flash image

ESP32D0WDQ6 4MB Flash

Download the firmware from the latest ci build.

The zip file contains:
1. The bootloader
2. The partition table
3. The firmware

```
 esptool.py -p COM5 -b 460800 --before default_reset --after hard_reset --chip esp32 write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 bootloader/bootloader.bin 0x8000 partition_table/partition-table.bin 0x10000 micropython.bin
```

![](./images/write-firmware.png)

# Credits

As far as I am aware OpenMV (https://openmv.io/) was the first micropython firmware to support tensorflow.  I copied extensively from their approach to get inference working in the hello world example and also for micro-speech example.

I started from their libtf code for how to interact with the Tensorflow C++ API from micropython:

https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.cc
and
https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.h 

The audio-frontend module originated by looking at how openmv connected to the tensorflow microfrontend here:
https://github.com/openmv/openmv/blob/3d9929eeae563c5b370ac86afa9216df50f0c079/src/omv/ports/stm32/modules/py_micro_speech.c
