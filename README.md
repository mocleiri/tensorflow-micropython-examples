# Tensorflow Lite for Microcontrollers in Micropython

The purpose of this project is to make a custom micropython firmware that installs tensorflow lite for micro controllers and allows for experimentation.

## Architecture

| Area        | Are           | 
| ------------- |:-------------:| 
| tensorflow-microlite.a | This is the tensorflow lite library with all operations to start with |
| micropython-modules/microlite | Micropython 'microlite' module that interconnects micropython to tensorflow lite |
| micropython-modules/audio_frontend | Wrapper for tensorflow experimental microfrontend audio processor needed by the micro_speech example to convert wav data into spectrogram data for processing by the model. |
| micropython-modules/ulab | We have a submodule dependency on [ulab](https://github.com/v923z/micropython-ulab).  |

At the moment all of the tensor operations are included in tensorflow-microlite.a but in the future we will try to externalize them so they can be brought on the file system with the model being run.


# Status

Tensorflow for ESP32 and Unix can be built and accessed by the microlite c/c++ module.  Inference is working for the hello-world example

I have ESP32 boards but it should work for other ports as well.

I am in progress on the micro_speech example.  I am able to read wav data from an INMP441 microphone using miketeachman's i2s module and am working on the audio_frontend needed to convert the wav data into spectogram format needed by the micro_speech model.

# Roadmap

Inference is working for the hello-world sine example.  

1. Implement the other modules:
2. Working on implementing micro speech.
3. Find way to externalize tensor op's from firmware

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

Next we need to link the micropython-ulab/code directory under micropython-modules so that the build can find it.

```
$ cd micropython-modules

$ ln -s ../micropython-ulab/code ulab

```

For building there are two main steps:
1. Build **tensorflow-microlite.a** which is the tensorflow library from the tensorflow sources using the port specific cross compiler.
2. Build micropython firmware which builds the microlite, audio_frontend and ulab modules.  At the moment we are also building the i2s module as we are on the miketeachman branch for this purpose to support dma sampling of audio for the microspeech example.

Building can be done using specially prepared docker images for esp32 and unix.  But mostly for the unix build I have been building in Microsoft Visual Studio Code through the linux subsystem for windows (to be documented)

## Docker Environments

There are two docker images:
1. build-environment for linux: docker/unix-build/Dockerfile
2. build-envionrment for esp32: esp-idf version 4.0.1 image, for building esp32.

### Make esp-idf docker image for version 4.0.1

At the moment to build using the esp32 idf version 4 we need to use version 4.0.1 which is just outside of the tags espressif publish in their dockerhub repository.  

I checked and 4.0.2 doesn't work right so you will need to first build a dockerfile from the latest esp-idf source code.

Build base esp-idf 4.0.1 Docker image:
1. Checkout the latest [esp-idf](https://github.com/espressif/esp-idf) then go into **tools/docker**.
2. docker build -t espressif-idf-v4.0.1 --build-arg IDF_CHECKOUT_REF=4c81978a3e2220674a432a588292a4c860eef27b .

This is the 4.0.1 version that micropython wants.  I have done the above steps and put the resultant image into dockerhub here:
https://hub.docker.com/r/mocleiri/esp-idf-4.0.1

Next in order to build the audio_frontend we need to have the xxd library installed.

The docker/esp32-build/Dockerfile can be used to create such an image.

```
$ docker build -t esp-idf-4.0.1-builder .
```

### Make unix build environment

The unix build environment needs to be built manually at the moment.

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

```
make -f tensorflow/lite/micro/tools/make/Makefile  TARGET=esp32  TOOLCHAIN=xtensa-esp32-elf-gcc CXX_TOOL=xtensa-esp32-elf-g++  CC_TOOL=xtensa-esp32-elf-gcc AR_TOOL=xtensa-esp32-elf-ar

```
 
use 'update-microlite.sh' script to copy the tensorflow static library into the lib directory.

# How to Build Micropython

## Build mpy-cross
```
git submodule update --recursive

cd micropython/mpy-cross

make
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
```
make -f /src/micropython-modules/microlite/GNUmakefile-esp32 V=1 PART_SRC=/src/custom-partitions.csv all

```

Note as-is the firmware is too big to fit into the default Micropython partition scheme on a 4MB flash board.  The custom-partitions.csv parition table increases the space for the application and decreases the amount of filesystem available.

I think there is about 1MB of flash filesystem and 3MB for the boot loader and application partitions.

# Flash image

ESP32D0WDQ6 4MB Flash

```

esptool.py --port COM5 erase_flash
esptool.py --chip esp32 --port COM5 write_flash -z 0x1000 esp32-20180511-v1.9.4.bin
```

![](./images/write-firmware.png)

# Credits

This firmware copied extensively from OpenMV.  Specifically starting from  


https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.cc
and
https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.h

And probably will use their approach for the micro speech example:
https://github.com/openmv/openmv/blob/3d9929eeae563c5b370ac86afa9216df50f0c079/src/omv/ports/stm32/modules/py_micro_speech.c
