Micropython implementation of the Person Detection Example

# Upstream example
https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/examples/person_detection/README.md

# Training the model

https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/examples/person_detection/training_a_model.md

# Files

## person_detect_model.tflite

I was able to restore the tflite model from the person_detection_int8 archive.  It was a .cc file but I converted it back into a binary file and verified the architecture in netron.


## person_image_data.dat

I was able to create this (96,96) binary file from the corresponding .cc file from the person_detection_int8 archive.

## no_person_image_data.dat

I was able to create this (96,96) binary file from the corresponding .cc file from the person_detection_int8 archive.

## show-test-images.py

A script that runs in python3 to load and display the two test images.