#!/bin/bash

TF_LITE=tensorflow/tensorflow/lite
TF_LITE_MICRO=$TF_LITE/micro

cp $TF_LITE_MICRO/tools/make/gen/esp_xtensa-esp32_default/lib/libtensorflow-microlite.a lib/libtensorflow-microlite.a

