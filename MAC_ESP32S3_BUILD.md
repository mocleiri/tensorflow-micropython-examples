# Build Tensorflow Micropython on MAC OS using Bash Terminal

Tested on: macOS Monterey Version 12.1

## Prerequisites 

# Properly Installing ESP-IDF (Taken from: https://docs.espressif.com/projects/esp-idf/en/v3.3/get-started-cmake/macos-setup.html)

sudo easy_install pip

pip install --user pyserial

brew install cmake ninja

brew install ccache

Download: https://dl.espressif.com/dl/xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz

mkdir -p ~/esp
cd ~/esp
tar -xzf ~/Downloads/xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz

# Make Toolchain Accessible from Bash Terminal 

Open your /bash.profile file by navigating to usr directory and pressing down the keys "Command, Shift, FullStop" it shoudl appear.

Add to your profile:

export PATH=$HOME/esp/xtensa-esp32-elf/bin:$PATH
alias get_esp32="export PATH=$HOME/esp/xtensa-esp32-elf/bin:$PATH"

# Git Clone ESP-IDF Version 4.4

cd ~/esp
git clone -b v4.4 --recursive https://github.com/espressif/esp-idf.git esp-idf

# Update the Submodules

cd esp-idf
git submodule update --init

# Reopen your /bash.profile and add the following:

export IDF_PATH=~/esp/esp-idf
export PATH="$IDF_PATH/tools:$PATH"

# Install the required python packages 

python3 -m pip install --user -r $IDF_PATH/requirements.txt

## Download the Tensorflow Micropython Examples Repo

git clone https://github.com/mocleiri/tensorflow-micropython-examples.git

## Building ESP32S3 

# Building the TensorFlow Firmware

cd /tensorflow-micropython-examples

git submodule init
git submodule update --recursive
cd micropython
git submodule update --init lib/axtls
git submodule update --init lib/berkeley-db-1.xx
cd ..

# Get Cache Keys

IDF_COMMIT=142bb32c50fa9875b8b69fa539a2d59559460d72
TFLM_COMMIT=$(git submodule status tensorflow | awk '{print ($1)}')

# Setup IDF within Repo (Another Option)

source ./micropython/tools/ci.sh && ci_esp32_idf44_setup

source ./esp-idf/export.sh

pip3 install Pillow
pip3 install Wave

rm -rf ./micropython-modules/microlite/tflm

cd ./tensorflow

../micropython-modules/microlite/prepare-tflm-esp.sh

cd ..

# Build Micropython Cross-Compiler 

source ./esp-idf/export.sh
cd ./micropython
make -C mpy-cross V=1 clean all

cd ..

# Build Generic ESP32S3 8MB FLASH

source ./esp-idf/export.sh 

(OR: get_esp32
get_idf)

cd ./boards/esp32/MICROLITE_S3

rm -rf build
idf.py clean build

# To build other boards e.g. GENERIC_SPIRAM replace with Board definition

cd ./boards/esp32/MICROLITE_S3_SPIRAM


If succesful you should see a reult similar to this:

/micropython.bin
or run 'idf.py -p (PORT) flash'
bootloader  @0x000000    18640  (   14128 remaining)
partitions  @0x008000     3072  (    1024 remaining)
application @0x010000  1191120  (  840496 remaining)
total                  1256656
