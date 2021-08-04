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

First the submodules need to be initialized.  We have 3:
1. tensorflow
2. micropython
3. ulab (micropython numpy equivelent)

```
git submodule init --recursive
```

For building there are two main steps:
1. Build **tensorflow-microlite.a** which is the tensorflow library from the tensorflow sources using the port specific cross compiler.
2. Build micropython firmware which builds the microlite, audio_frontend and ulab modules.  At the moment we are also building the i2s module as we are on the miketeachman branch for this purpose to support dma sampling of audio for the microspeech example.


Building for esp32 can be done using the [Espressif idf docker images](https://hub.docker.com/r/espressif/idf):
1. espressif/idf:v4.0.2
2. espressif/idf:release-v4.1
3. espressif/idf:release-v4.2
4. espressif/idf:release-v4.3

Buiding for the unix port can be done using visual studio in the windows subsystem for linux mode.  The necessary build and debug actions are contained within the repository (Detailed Documentation to follow).

## Docker Environments

https://github.com/mocleiri/tensorflow-micropython-examples/blob/master/build-with-docker-idf.sh

```
$ build-with-docker-idf.sh espressif/idf:v4.0.2
```

### Helper Scripts


1. build-with-unix-docker.sh; this uses the unix-build image and mounts the project as /src in the container.

2. build-with-docker-idf.sh; this uses the esp-idf 4.0.1 image and mounts the project as /src in the container.

# How to Build Tensorflow

## Build for Unix 

```
cd /src/tensorflow

make -f tensorflow/lite/micro/tools/make/Makefile [BUILD_TYPE=debug]

# should put this into the script
cp tensorflow/lite/micro/tools/make/gen/linux_x86_64/lib/libtensorflow-microlite.a /src/lib

```

Specify BUILD_TYPE=debug if you want to be able to debug the resultant code. 

## Build for ESP32

Start the docker image using: 
```
./build-with-docker-idf.sh [optional: name of docker image to use]

```

Run the build using the helper script which has the appropriate compile time flags needed when linking into the micropython firmware.  At the moment this script is esp32 specific.
```
$ cd /src

$ ./build-tensorflow-lite-micro.sh clean all

```
 
use 'update-microlite.sh' script to copy the tensorflow static library into the lib directory which is where micropython will pick it up from when linking the esp32 firmware.

```
$ cd /src

$ ./update-microlite.sh
copies: tensorflow/lite/micro/tools/make/gen/esp32_xtensa-esp32/lib/libtensorflow-microlite.a /src/lib
```

# How to Build Micropython

## Build mpy-cross
```
git submodule update --recursive

cd micropython/mpy-cross

root@3453c74a93f6:/src/micropython# make -C mpy-cross V=1 CROSS_COMPILE=xtensa-esp32-elf- clean all
```

Make sure to use the correct cross compiler if needed.

## Build for Unix 


```
cd /src/micropython

git submodule update --init lib/axtls

git submodule update --init lib/berkeley-db-1.xx

cd ports/unix

make -f /src/src/GNUmakefile-unix V=1

```

## Build for ESP32

Be sure to be building inside of the idf docker container:
```
root@3453c74a93f6:~# cd /src/micropython/ports/esp32

root@3453c74a93f6:/src/micropython/ports/esp32# make BOARD=MICROLITE USER_C_MOOULES=/src/micropython-modules/micropython.cmake

```

Note as-is the firmware is too big to fit into the default Micropython partition scheme on a 4MB flash board.  There is a custom-partitions.csv parition table increases the space for the application and decreases the amount of filesystem available.  This is the main difference of the MICROLITE board from the GENERIC board.


I think there is about 1MB of flash filesystem and 3MB for the boot loader and application partitions.

### Additional Board configurations

The MICROLITE_SPIRAM_16M board definition also exists.  It creates the microlite firmware for boards with SPIRAM and 16 MB of Flash.  There is 3MB allocated to the firmware and 13 MB available for the flash file-system.

```
$ make BOARD=MICROLITE_SPIRAM_16M USER_C_MODULES=/src/micropython-modules/micropython.cmake
```

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
