# Tensorflow Lite for Microcontrollers in Micropython

The purpose of this project is to make a custom micropython firmware that installs tensorflow lite for micro controllers and allows for experimentation.

## Architecture

| Area        | Are           | 
| ------------- |:-------------:| 
| tensorflow-microlite.a | This is the tensorflow lite library with all operations to start with |
| src/microlite | Micropython 'microlite' module that interconnects micropython to tensorflow lite |

In the future when interference works I will build other parts as native modules which can then be loaded as needed depending on which problem is being solved.




# Status

Tensorflow for ESP32 and Unix can be built and accessed by the microlite c/c++ module.  Inference is not yet working.

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

# About Tensorflow

At the moment we are using the r2.4 branch in tensorflow and then using the user implementation Makefile to build the full tensorflow lite for microcontroller library.

Later we will try to move the ops out into something that can be wrapped as a native micropython module and added via being on the file system.

# About Micropython

For the micros-speech example we are using a custom version of micropython with miketeachman's i2s module added for esp32 plus a few other changes related to getting the build to work right.

Probably if you don't need that then you could build from either the last release or master instead.

# How to Build

First we need to get the micropython and tensorflow submodules.

Next we need to build **tensorflow-microlite.a** which is the tensorflow library using the cross compiler of the target port.

Then we copy library into the top level lib directory and go and build micropython which refers to the top level library to include into the firmware.

Building can be done using specially prepared docker images.

## Docker Environments

There are two docker images:
1. build-environment for linux: docker/unix-build/Dockerfile
2. esp-idf version 4.0.1 image, for building esp32.

The esp-idf image was made from the upstream dockerfile but just for 4.0.1 which is currently needed to build Micropython but not released in Espressif's current docker repository.

Its available in dockerhub here: https://hub.docker.com/r/mocleiri/esp-idf-4.0.1

The unix build environment needs to be built manually at the moment.

There are helper scripts:
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
make -f tensorflow/lite/micro/tools/make/Makefile  TARGET=esp32  TOOLCHAIN=xtensa-esp32-elf-gcc CXX
_TOOL=xtensa-esp32-elf-g++  CC_TOOL=xtensa-esp32-elf-gcc AR_TOOL=xtensa-esp32-elf-ar

```
 
use 'update-microlite.sh' script to copy the tensorflow static library into the lib directory.

# How to Build Micropython

## Build for Unix 


```
cd /src/micropython

git submodule update --init lib/axtls

cd ports/unix

make -f /src/src/GNUmakefile-unix V=1

```

## Build for ESP32
```
make -f /src/src/GNUmakefile V=1 PART_SRC=/src/custom-partitions.csv all
```

Note as-is the firmware is too big to fit into the default Micropython partition scheme on a 4MB flash board.  The custom-partitions.csv parition table increases the space for the application and decreases the amount of filesystem available.

I think there is about 1MB of flash filesystem and 3MB for the boot loader and application partitions.

# Flash image

ESP32D0WDQ6 4MB Flash

```

esptool.py --port COM5 erase_flash
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash -z 0x1000 esp32-20180511-v1.9.4.bin
```

![](./images/write-firmware.png)

# Credits

This firmware copied extensively from OpenMV.  Specifically starting from  


https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.cc
and
https://github.com/openmv/tensorflow-lib/blob/343fe84c97f73d2fe17a0ed23540d06c782fafe7/libtf.h

And probably will use their approach for the micro speech example:
https://github.com/openmv/openmv/blob/3d9929eeae563c5b370ac86afa9216df50f0c079/src/omv/ports/stm32/modules/py_micro_speech.c
