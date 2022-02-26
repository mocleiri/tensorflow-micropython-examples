# Run the person detection model
# This version reads the images from the ov2640 camera on the esp32-cam board
# with minor changes this also works for the m5 timer camera

import sys
import microlite
import camera
from machine import Pin,PWM

# initialize the camera to read 96x96 pixel gray scale images

try:

	# uncomment for esp32-cam-mb with ov2640 sensor
	camera.init(0,format=camera.GRAYSCALE,framesize=camera.FRAME_96X96)

	# uncomment for the m5 timer camera with ov3660 sensor
	# camera.init(0,format=camera.GRAYSCALE,framesize=camera.FRAME_96X96,
	#            sioc=23,siod=25,xclk=27,vsync=22,href=26,pclk=21,
	#            d0=32,d1=35,d2=34,d3=5,d4=39,d5=18,d6=36,d7=19,
	#            reset=15)
except:
	print("Error when initializing the camera")
	sys.exit()

# initialize the flash-light LED, it is connected to GPIO 4
flash_light = PWM(Pin(4))
# switch it off
flash_light.duty(0)

# change for m5 timer camera
# # initialize the flash-light LED, it is connected to GPIO 4
#  flash_light = Pin(2,Pin.OUT)
# switch it off
# flash_light.off()

mode = 1
test_image = bytearray(9612)

def handle_output(person):
	if person > 10:
		flash_light.duty(5)
		# if m5 timer camera
        # flash_light.on()
	else:
		flash_light.duty(0)
		# if m5 timer camera
        # flash_light.off()
        
def input_callback (microlite_interpreter):    
	inputTensor = microlite_interpreter.getInputTensor(0)
	for i in range (0, len(test_image)):
		inputTensor.setValue(i, test_image[i])
	print ("setup %d bytes on the inputTensor." % (len(test_image)))

def output_callback (microlite_interpreter):
	outputTensor = microlite_interpreter.getOutputTensor(0)
	not_a_person = outputTensor.getValue(0)
	person = outputTensor.getValue(1)
	print ("'not a person' = %d, 'person' = %d" % (not_a_person, person))
	handle_output(person)

# read the model
person_detection_model_file = open ('person_detect_model.tflite', 'rb')
person_detection_model = bytearray (300568)
person_detection_model_file.readinto(person_detection_model)
person_detection_model_file.close()

# create the interpreter
interp = microlite.interpreter(person_detection_model,136*1024, input_callback, output_callback)

# Permanently read images from the camera and pass them into the model for
# inference

while True:
	test_image = camera.capture()
	interp.invoke()

camera.deinit()
