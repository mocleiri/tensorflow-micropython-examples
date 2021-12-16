#!/bin/bash
# needs to be run from the tensorflow top level directory
python3 ./tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py \
          --examples micro_speech --rename-cc-to-cpp ../micropython-modules/microlite/tflm
