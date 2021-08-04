# Copyright 2021 The TensorFlow Micropython Examples rs. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# Tests the microcontroller code for esp32 platform

set -e

BASE_DIR=/opt/tflite-micro-micropython

#cd $BASE_DIR/tensorflow

# need to run the downloads again so the headers are available
#make -f tensorflow/lite/micro/tools/make/Makefile third_party_downloads 

# need to download the kissft dependency.
# make -f tensorflow/lite/micro/tools/make/Makefile generate_hello_world_make_project


#cd $BASE_DIR/micropython-modules/audio_frontend

# at the moment micropython esp32 port doesn't work with .cc extension c++ files only .cpp
# so copy to rename the line ending
#cp $BASE_DIR/tensorflow/tensorflow/lite/experimental/microfrontend/lib/fft.cc fft.cpp
#cp $BASE_DIR/tensorflow/tensorflow/lite/experimental/microfrontend/lib/fft_util.cc fft_util.cpp

cd $BASE_DIR/micropython

pwd

echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all

echo "cd $BASE_DIR/boards/esp32/MICROLITE_SPIRAM_16M"
cd $BASE_DIR/boards/esp32/MICROLITE_SPIRAM_16M

pwd

echo "Building MICROLITE_SPIRAM_16M"
rm -rf builds
idf.py clean build
