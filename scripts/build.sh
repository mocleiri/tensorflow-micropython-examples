#!bin/bash

MAKEOPTS=

# if which nproc > /dev/null; then
#     MAKEOPTS="-j$(nproc)"
# else
#     MAKEOPTS="-j$(sysctl -n hw.ncpu)"
# fi

function prepare_dependencies {

    rm -rf dependencies

    mkdir dependencies

    cd dependencies

    ULAB_VERSION=6.0.12
    #MICRO_PYTHON_VERSION=v1.20.0
    MICRO_PYTHON_VERSION=master
    MICROPYTHON_ESP32_CAMERA_DRIVER=master
    ESP32_TFLITE_VERSION=v1.0.0

    # ulab
    git clone --depth 1 https://github.com/v923z/micropython-ulab --branch $ULAB_VERSION

    # micropython
    git clone --depth 1 https://github.com/micropython/micropython --branch $MICRO_PYTHON_VERSION

    # esp32 - https://github.com/mocleiri/tensorflow-micropython-examples.git
    git clone --depth 1 https://github.com/espressif/tflite-micro-esp-examples --branch $ESP32_TFLITE_VERSION

    # esp32-camera actually comes through esp package manager but we need it for the headers
    git clone --depth 1 https://github.com/espressif/esp32-camera --branch master

    # micropypthon camera driver
    git clone --depth 1 https://github.com/lemariva/micropython-camera-driver --branch $MICROPYTHON_ESP32_CAMERA_DRIVER

    # other platforms - get tflite-micro and run create_tflm_tree.py
    # refer to 
    git clone --depth 1 https://github.com/tensorflow/tflite-micro

    # build : 
    # $ cd dependencies/micropython/ports/esp32
    # $ 
    # cd micropython
    # git submodule init
    # git submodule update --recursive

    # cd ../..
    cd ..
}

function build_esp32 {
    BOARD=$1
    if test -z "$BOARD"; then
    	echo "USAGE: build_esp32 <microlite board name>"
	    exit 1;
    fi
    pwd
    python --version
    which python
    # xargs --show-limits
    source esp-idf/export.sh
    cd dependencies/micropython
    make ${MAKEOPTS} -C mpy-cross
    cd ports/esp32
    make ${MAKEOPTS} submodules
    
    PWD=$(pwd)
    echo "make ${MAKEOPTS} V=1 BOARD_DIR=$(pwd)/../../../../boards/esp32/${BOARD} BOARD=${BOARD} FROZEN_MANIFEST=$PWD/boards/manifest.py"

    make ${MAKEOPTS} V=1 \
        BOARD_DIR=$(pwd)/../../../../boards/esp32/${BOARD} \
        BOARD=${BOARD} 

    # creates the build into dependencies/micropython/ports/esp32/build-MICROLITE
    # find build-${BOARD} -ls
    cd ../../../..
}



