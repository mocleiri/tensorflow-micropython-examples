#!/bin/bash

Copy () {

	BASE_DIR=$1

	find $BASE_DIR -iname *.h | grep -v make\/downloads | grep -v examples | while read FP; do

		BASE_FP=$(basename $FP)
		DIR_FP=$(dirname $FP)


		mkdir -p include/$DIR_FP
		cp $FP include/$DIR_FP
		echo "cp $FP include/$DIR_FP"

	done



}

TF_LITE=tensorflow/tensorflow/lite
TF_LITE_MICRO=$TF_LITE/micro

cp $TF_LITE_MICRO/tools/make/gen/esp_xtensa-esp32/lib/libtensorflow-microlite.a lib

rm -rf include

Copy $TF_LITE_MICRO

cp $TF_LITE/*.h include/$TF_LITE


Copy "$TF_LITE/c"
Copy "$TF_LITE/core"
Copy "$TF_LITE/schema"
Copy "$TF_LITE/kernels"

Copy "$TF_LITE_MICRO/tools/make/downloads/flatbuffers/include"


