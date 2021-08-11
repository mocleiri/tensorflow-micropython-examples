import microlite

mode = 1

test_image = bytearray(9612)



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
    

person_detection_model_file = open ('person_detect_model.tflite', 'rb')

person_detection_model = bytearray (300568)

person_detection_model_file.readinto(person_detection_model)

person_detection_model_file.close()

interp = microlite.interpreter(person_detection_model,136*1024, input_callback, output_callback)

print("Classify No Person Image")

no_person_test_image_file = open ('no_person_image_data.dat', 'rb')

no_person_test_image_file.readinto(test_image)

no_person_test_image_file.close()

interp.invoke()

print("Classify Person Image")

no_person_test_image_file = open ('person_image_data.dat', 'rb')

no_person_test_image_file.readinto(test_image)

no_person_test_image_file.close()

interp.invoke()