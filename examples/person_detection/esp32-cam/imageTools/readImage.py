# Reads a 96x96 pixel gray scale image from the camera in raw mode
# This image can directly be passed into the input tensor of the
# person detection model
# The program is part of a course on AI and edge computing at the
# University of Cape Coast, Ghana
# Copyright (c) U. Raich [2022]
# The program is released under the MIT License

import sys
import camera
from utime import sleep_ms

try:
    camera.init(0,format=camera.GRAYSCALE,framesize=camera.FRAME_96X96)
except:
    print("Error when initializing the camera")
    sys.exit()
    
buf=camera.capture()
print("type: ", type(buf), " Length: ",len(buf))
# save the raw image to a file
print("Writing the data to camImage.raw")
if len(buf) == 96*96:
    f = open("camImage.raw","w+b")
    f.write(buf)
    f.close()
    
camera.deinit()
