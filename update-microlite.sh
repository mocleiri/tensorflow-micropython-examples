#!/bin/bash

TF_LITE=tensorflow/tensorflow/lite
TF_LITE_MICRO=$TF_LITE/micro

cp $TF_LITE_MICRO/tools/make/gen/esp32_xtensa-esp32/lib/libtensorflow-microlite.a lib

