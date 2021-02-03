#!/bin/bash

cd ../../tensorflow

# remove build details
rm -rf tensorflow/lite/micro/tools/make/gen
rm -rf tensorflow/lite/micro/tools/make/downloads

# need to download the kissft dependency.
make -f tensorflow/lite/micro/tools/make/Makefile generate_hello_world_make_project


cd ../micropython-modules/audio_frontend

# at the moment micropython esp32 port doesn't work with .cc extension c++ files only .cpp
# so copy to rename the line ending
cp ../../tensorflow/tensorflow/lite/experimental/microfrontend/lib/fft.cc fft.cpp
cp ../../tensorflow/tensorflow/lite/experimental/microfrontend/lib/fft_util.cc fft_util.cpp
