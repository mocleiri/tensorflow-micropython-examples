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

cd $BASE_DIR/micropython

make -C mpy-cross V=1 clean All


cd ports/esp32

make BOARD=MICROLITE USER_C_MOOULES=/src/micropython-modules/micropython.cmake

make BOARD=MICROLITE_SPIRAM_16M USER_C_MOOULES=/src/micropython-modules/micropython.cmake







