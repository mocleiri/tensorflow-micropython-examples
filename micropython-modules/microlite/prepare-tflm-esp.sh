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

mkdir -p ../micropython-modules/microlite/esp_nn/include

# copy esp-nn
cp ../tflm_esp_kernels/components/esp-nn/include/esp_nn.h ../micropython-modules/microlite/esp_nn/include
cp ../tflm_esp_kernels/components/esp-nn/include/esp_nn_ansi_headers.h ../micropython-modules/microlite/esp_nn/include
cp ../tflm_esp_kernels/components/esp-nn/include/esp_nn_esp32.h ../micropython-modules/microlite/esp_nn/include
cp ../tflm_esp_kernels/components/esp-nn/include/esp_nn_esp32s3.h ../micropython-modules/microlite/esp_nn/include
cp ../tflm_esp_kernels/components/esp-nn/include/esp_nn_ansi_c.h ../micropython-modules/microlite/esp_nn/include

tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s8_esp32s3.c
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_conv_s16_mult8_1x1_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_conv_s16_mult4_1x1_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult4_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult1_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_conv_esp32s3.c
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_conv_ansi.c
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult8_3x3_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_ansi.c
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult1_3x3_no_pad_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s8_mult1_3x3_padded_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_conv_s16_mult8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/convolution/esp_nn_depthwise_conv_s16_mult1_3x3_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/activation_functions/esp_nn_relu_s8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/activation_functions/esp_nn_relu_ansi.c
tflm_esp_kernels/components/esp-nn/src/pooling/esp_nn_max_pool_s8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/pooling/esp_nn_max_pool_ansi.c
tflm_esp_kernels/components/esp-nn/src/pooling/esp_nn_avg_pool_s8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/pooling/esp_nn_avg_pool_ansi.c
tflm_esp_kernels/components/esp-nn/src/common/esp_nn_multiply_by_quantized_mult_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/common/esp_nn_common_functions_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/common/esp_nn_multiply_by_quantized_mult_ver1_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/basic_math/esp_nn_add_s8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/basic_math/esp_nn_mul_ansi.c
tflm_esp_kernels/components/esp-nn/src/basic_math/esp_nn_mul_s8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/basic_math/esp_nn_add_ansi.c
tflm_esp_kernels/components/esp-nn/src/fully_connected/esp_nn_fully_connected_s8_esp32s3.S
tflm_esp_kernels/components/esp-nn/src/fully_connected/esp_nn_fully_connected_ansi.c


# copy kernels
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/add.cc ../micropython-modules/microlite/esp_nn/add.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/conv.cc ../micropython-modules/microlite/esp_nn/conv.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/depthwise_conv.cc ../micropython-modules/microlite/esp_nn/depthwise_conv.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/fully_connected.cc ../micropython-modules/microlite/esp_nn/fully_connected.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/mul.cc ../micropython-modules/microlite/esp_nn/mul.cpp
cp ../tflm_esp_kernels/components/tflite-lib/tensorflow/lite/micro/kernels/esp_nn/pooling.cc ../micropython-modules/microlite/esp_nn/pooling.cpp
    
