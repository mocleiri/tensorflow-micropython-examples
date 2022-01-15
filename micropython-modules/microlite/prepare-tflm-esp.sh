#!/bin/bash
# needs to be run from the tensorflow top level directory

rm -rf ./tensorflow/lite/micro/tools/make/downloads
rm -rf ./tensorflow/lite/micro/tools/make/gen
rm -rf ../micropython-modules/microlite/tflm

python3 ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
          --examples micro_speech --rename_cc_to_cpp ../micropython-modules/microlite/tflm

# copy optimized kernels over
# this is a temporary solution until the kernels put upstream into tflm

rm -rf ../micropython-modules/microlite/esp_nn

mkdir -p ../micropython-modules/microlite/esp_nn

cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/add.cc ../micropython-modules/microlite/esp_nn/add.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/conv.cc ../micropython-modules/microlite/esp_nn/conv.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/depthwise_conv.cc ../micropython-modules/microlite/esp_nn/depthwise_conv.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/fully_connected.cc ../micropython-modules/microlite/esp_nn/fully_connected.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/mul.cc ../micropython-modules/microlite/esp_nn/mul.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/pooling.cc ../micropython-modules/microlite/esp_nn/pooling.cpp
    