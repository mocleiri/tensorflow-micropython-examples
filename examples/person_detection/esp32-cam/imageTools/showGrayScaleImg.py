#!/usr/bin/python3
from PIL import Image
import io,sys

if len(sys.argv) != 2:
  print("Usage %s filename"%sys.argv[0])
  sys.exit()

image_data_file = open (sys.argv[1], 'rb')
image_data = bytearray(9612)
image_data_file.readinto(image_data)
image_data_file.close()
image = Image.frombytes ('L', (96,96), bytes(image_data) ,'raw')
image.show()


