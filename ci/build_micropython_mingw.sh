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
#
set -e

# probably I should fold this into the docker container but at the moment we are using the
# espressif idf container using the regular gcc compiler and this installs the ffi.h header which is
# needed by modffi.c
apt-get update && apt-get install -y libffi-dev pkg-config

BASE_DIR=/opt/tflite-micro-micropython

cd $BASE_DIR/micropython

pwd

echo "make -C mpy-cross V=1 clean all"
make -C mpy-cross V=1 clean all


cd ports/windows

pwd

echo "Building unix micropython"
rm -f micropython
make submodules
make deplibs
make -f $BASE_DIR/micropython-modules/GNUmakefile-mingw V=1
