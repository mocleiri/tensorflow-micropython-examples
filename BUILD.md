# Build Tensorflow Micropython

First we need to build tensorflow to which results in a libtensorflow-microlite.a static library.

Then we have 3 micropython modules:
1. microlite (ours, tensorflow micropython bindings and links to libtensorflow-microlite.a)
2. audio_frontend (ours, micropython bindings to tensorflow lite experimental audiofrontend.)
3. ulab (submodule)

We have a boards/<micropython port>/<board config> and we will build each board with the above 3 modules.

For building there are two main steps:
1. Build **tensorflow-microlite.a** which is the tensorflow library from the tensorflow sources using the port specific cross compiler.
2. Build micropython firmware which builds the microlite, audio_frontend and ulab modules.  

# Consult Continuous Integration Scripts for latest

The documentation here is mostly up to date but the latest is what is currently working for the github actions.

1. [Unix Build](.github/workflows/build_unix.yml) 
2. [ESP32 Build](.github/workflows/build_esp32.yml)

# Docker Build Containers

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

root@3453c74a93f6:/src/micropython# make -C mpy-cross V=1 clean all
```
You need to build the cross compiler for the host you are on which is typically linux gcc.  In the esp-idf container
you can use regular gcc which is for x86.

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
`
