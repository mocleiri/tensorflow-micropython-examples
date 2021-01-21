# Microlite implementation of the tensorflow hello-world example
# https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/micro/examples/hello_world
import microlite

counter = 1

kXrange = 2.0 * 3.14159265359

current_input = None


def input_callback (microlite_interpreter):

    global current_input

    # print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    inputTensor = microlite_interpreter.getInputTensor(0)

    # print (inputTensor)

    position = (counter*1.0) / 1.0

    # print ("position %f" % position)

    x = position * kXrange

    current_input = x
    # print ("x: %f, " % x)

    x_quantized = inputTensor.quantizeFloatToInt8(x)

    inputTensor.setValue(0, x_quantized)

def output_callback (microlite_interpreter):
    global current_input
    # print ("output callback")

    outputTensor = microlite_interpreter.getOutputTensor(0)

    # print (outputTensor)

    y_quantized = outputTensor.getValue(0)
    
    y = outputTensor.quantizeInt8ToFloat(y_quantized)

    print ("%f,%f" % (current_input,y))



interp = microlite.interpreter(2048, input_callback, output_callback)

print ("time step,y")
for c in range(1000):
    interp.invoke()
    counter = counter + 1