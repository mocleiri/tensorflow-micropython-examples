# Build Tensorflow Micropython

If you were building from scratch before 2021-12-15 then follow the [Upgrade Instructions](UPGRADE.md).

If you need instructions on how to debug on ESP32 or STM32 on device using JTAG then follow the [On Device Debugging Instructions](DEBUGGING.md)

## Overview 
We use the Micropython USER_C_MODULES extension mechanism for building a firmware with the microlite module and ulab
included.

The tensorflow lite micro code is generated using the [tensorflow/tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py](https://github.com/mocleiri/tflite-micro/blob/main/tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py)
python script.

Depending on the port it works in conjunction with the ./tensorflow/lite/micro/tools/make/Makefile to generate the source files
for the tensorflow lite micro project suitable for inclusion in downstream projects.

Some ports like stm32 and rp2 have custom kernels that are provided in place of the reference kernels.

There is a per port script within the micropython-modules/microlite directory that will invoke this script with the correct
options.

* [prepare-tflm-esp.sh](https://github.com/mocleiri/tensorflow-micropython-examples/blob/main/micropython-modules/microlite/prepare-tflm-esp.sh)
* [prepare-tflm-rp2.sh](https://github.com/mocleiri/tensorflow-micropython-examples/blob/main/micropython-modules/microlite/prepare-tflm-rp2.sh)
* [prepare-tflm-stm32.sh](https://github.com/mocleiri/tensorflow-micropython-examples/blob/main/micropython-modules/microlite/prepare-tflm-stm32.sh)

Running the applicable script will create a tflm subdirectory within micropython-modules/microlite and it is under this
where all of the tensorflow c++ files are located.


## Building ESP32

Instructions for [building ESP32S3 on MAC OS](MAC_ESP32S3_BUILD.md).

Remember to have built mpy-cross before building the board itself.

### Prerequisites
pip3 install Pillow
pip3 install Wave

The esp-idf is provisioned through the micropython/tools/ci.sh script.  We tie into the same tooling used by
micropython to build esp32.

If you have the idf installed somewhere else you can use that instead.  The shells running the build steps just
need to have been configured by esp-idf/export.sh prior to running commands.

###  Setup submodules

```shell
git submodule init
git submodule update --recursive
cd micropython
git submodule update --init lib/axtls
git submodule update --init lib/berkeley-db-1.xx
cd ..
```

### Generate Tensorflow Micro source files

```shell
echo "Regenerating microlite/tfm directory"
rm -rf ./micropython-modules/microlite/tflm

cd ./tensorflow

../micropython-modules/microlite/prepare-tflm-esp.sh
```

### Build mpy-cross before building the board

```shell
source ./esp-idf/export.sh
cd ./micropython
echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all
```

### Build Board

We should be able to support all micropython boards for the esp32 port.  However, at the moment we have our own directory
boards/esp32 which a further subdirectory for the boards we build.

Issues are welcome to request that we support new boards.  

I'm considering implementing the building logic ontop of micropython's auto build logic which would allow a microlite
build for all boards supported by the ports supported.



```shell
$ source ./esp-idf/export.sh
$ cd boards/esp32/MICROLITE
$ rm -rf build
$ idf.py build
```

After the successful build the build directory will contain:
1. bootloader/bootloader.bin 
2. partition_table/partition-table.bin 
3. micropython.bin

These can then be flashed onto your board.

## Building RP2

For CI we use the micropython/tools/ci.sh script to install the arm gcc toolchain.  You probably want to have it installed
somewhere permanently and have it available so that it will be used by the build steps below.

### Prerequisites
pip3 install Pillow
pip3 install Wave

###  Setup submodules

```shell
git submodule init
git submodule update --recursive
cd micropython
git submodule update --init lib/pico-sdk lib/tinyusb
cd ..
```

### Generate Tensorflow Micro source files

```shell
echo "Regenerating microlite/tfm directory"
rm -rf ./micropython-modules/microlite/tflm

cd ./tensorflow

../micropython-modules/microlite/prepare-tflm-rp2.sh
```
### Build mpy-cross before building the board

```shell
cd ./micropython
echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all
```

### Build Board

RP2 doesn't have the same external build configuration like esp32 and stm32 have so I have it implemented for all
of the boards defined by micropython for rp2.

```shell
  cd micropython
  cmake -S ports/rp2 -B build-PICO -DPICO_BUILD_DOCS=0 -DMICROPY_BOARD=PICO \
-DUSER_C_MODULES=/home/runner/work/tensorflow-micropython-examples/tensorflow-micropython-examples/micropython-modules/micropython.cmake

  cd build-PICO
  make
```
The path needs to be absolute so you would change /home/runner/work/tensorflow-micropython-examples to be the prefix on
your system where the project was cloned to.

The firmware files are located within micropython/build-PICO.  The firmware.uf2 can be used to flash the board.

## Building STM32


For CI we use the micropython/tools/ci.sh script to install the arm gcc toolchain.  You probably want to have it installed
somewhere permanently and have it available so that it will be used by the build steps below.

### Prerequisites
pip3 install Pillow
pip3 install Wave

###  Setup submodules

```shell
git submodule init
git submodule update --recursive
cd micropython
git submodule update --init lib/mynewt-nimble
cd ..
```

### Generate Tensorflow Micro source files

```shell
echo "Regenerating microlite/tfm directory"
rm -rf ./micropython-modules/microlite/tflm

cd ./tensorflow

../micropython-modules/microlite/prepare-tflm-stm32.sh
```
### Build mpy-cross before building the board

```shell
cd ./micropython
echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all
```

### Build Board

RP2 doesn't have the same external build configuration like esp32 and stm32 have so I have it implemented for all
of the boards defined by micropython for rp2.

```shell
cd micropython-modules
ln -s ../micropython-ulab/code  ulab
cd ..

echo "cd ./boards/stm32/NUCLEO_H743ZI2_MICROLITE"
cd ./boards/stm32/NUCLEO_H743ZI2_MICROLITE

echo "Building NUCLEO_H743ZI2_MICROLITE"
rm -rf build
make V=1
```

You can then flash the firmware with build/micropython.elf using the stm32cubeprogrammer.

# Github Actions for reference

The documentation here is mostly up to date but the latest is what is currently working for the github actions.

1. [ESP32 Builds](.github/workflows/build_esp32.yml)
2. [ESP32 S3 Builds](.github/workflows/build_esp32s3.yml)
2. [RP2 Build](.github/workflows/build_rp2.yml)
2. [STM32 Builds](.github/workflows/build_stm32.yml)
2. [Unix Build](.github/workflows/build_unix.yml)
