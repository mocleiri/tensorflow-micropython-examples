# Tensorflow Lite for Microcontrollers in Micropython

The purpose of this project is to make a custom micropython firmware that installs tensorflow lite for micro controllers and allows for experimentation.

I want to incubate this project here but if it is successful at enabling tensorflow lite for microcontroller models to be run from micropython I will explore how to merge the microlite and audio_frontend modules into the tensorflow for microcontrollers upstream repository.

## Architecture

| Area        | Are           | 
| ------------- |:-------------:| 
| tensorflow-microlite.a | This is the tensorflow lite micro library with all operations to start with |
| micropython-modules/microlite | Micropython 'microlite' module that interconnects micropython to tensorflow lite micropython c++ api |
| micropython-modules/audio_frontend | Micropython Wrapper for tensorflow experimental microfrontend audio processor needed by the micro_speech example to convert wav data into spectrogram data for processing by the model. |
| micropython-modules/ulab | We have a submodule dependency on [ulab](https://github.com/v923z/micropython-ulab).  |

At the moment all of the tensor operations are included in tensorflow-microlite.a but in the future we will try to externalize them so they can be brought on the file system with the model being run.

Because we have all of the operations there is a cost in the size of the image generated.


# Port Status

Build Type | Status |
 --------- | ------ |
ESP32   | [![ESP32](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_esp32.yml) |
UNIX   | [![UNIX](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_unix.yml/badge.svg)](https://github.com/mocleiri/tensorflow-micropython-examples/actions/workflows/build_unix.yml) |


# Prebuilt Firmware

The latest firmware can be downloaded from the applicable build above (in the Status section).
1. Click on build status link.
2. Click on the latest green build
3. Review the available artifiacts for download

You do need to be careful to get the proper firmware for your board.  If your board is not currently being built please file an issue and it can be added.

![](./images/download-esp32-artifact.png)

# Examples

## Hello World

Give a model an x value and it will give a y value.  The chart of such points is an approximate sine wave:
![](./images/hello-world-output-chart.png)

Status:
* Works on unix port and esp32 port.

[Hello-World Documentation](examples/hello-world/README.md)

## Micro Speech 

Process:
1. Sample Audio
2. Convert to spectrogram
3. Set 1960 bytes on input tensor corresponding to 1 second worth of spectrogram.
4. Run inference on model 3-4 times per second and average scores.
5. Scores over 200 indicate a match

Status:
* Works on unix port with files.
* Works on esp32 no-spi ram board with machine.I2S.

[Micro Speech Documentation](examples/micro-speech/README.md)

## Person Detection

Process:
1. Capture Images
2. Convert to 96x96 pixel int8 greyscale images
3. Set on input later of model
4. Run inference on image
5. if person > no person it thinks the image is a person
6. if no person > person it thinks the image contains no person

Status:
* Works on unix port and esp32 port using files.

[Person Detection Documentation](examples/person_detection/README.md)

## Magic Wand

[TODO #5](https://github.com/mocleiri/tensorflow-micropython-examples/issues/5)

# Roadmap

Almost all of the examples work now.

| # | Description | Issue |
| --- | --- | --- |
| 1. | Adjust microlite api to match tflite python api (at least a subset).  We don't really need the callback approach anymore. |  https://github.com/mocleiri/tensorflow-micropython-examples/issues/10 |
| 2. | Cleanup micro_speech implementation | |
| 3. | Implement the magic wand example | https://github.com/mocleiri/tensorflow-micropython-examples/issues/5 |
| 4. | Investigate automatic tensor quantization | https://github.com/mocleiri/tensorflow-micropython-examples/issues/6 |
| 5. | Find way to externalize tensor op's from firmware | https://github.com/mocleiri/tensorflow-micropython-examples/issues/7 |

# About Tensorflow

At the moment we are using the main branch in the tensorflow lite micro repository.

This is the c++ api version of tensorflow lite designed to run on microcontrollers.

At the moment we are building everything and linking it into the micropython firmware.

The next steps are to try and find ways to use build switches or native modules to support
smaller firmware sizes.

# About Micropython

We are building from micropython master.  

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

As far as I am aware OpenMV (https://openmv.io/) was the first micropython firmware to support tensorflow.  

I copied extensively from their approach to get inference working in the hello world example and also for micro-speech example.

I started from their libtf code for how to interact with the Tensorflow C++ API from micropython:

https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.cc
and
https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.h 

The audio-frontend module originated by looking at how openmv connected to the tensorflow microfrontend here:
https://github.com/openmv/openmv/blob/3d9929eeae563c5b370ac86afa9216df50f0c079/src/omv/ports/stm32/modules/py_micro_speech.c
