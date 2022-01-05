# Microlite implementation of the tensorflow hello-world example
# https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/micro/examples/hello_world
import microlite
import io

counter = 1

kXrange = 2.0 * 3.14159265359
steps = 1000
current_input = None


def input_callback (microlite_interpreter):

    global current_input

    inputTensor = microlite_interpreter.getInputTensor(0)

    # print (inputTensor)

    position = counter*1.0

    # print ("position %f" % position)

    x = position * kXrange/steps

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

hello_world_model = bytearray(2488)

model_file = io.open('model.tflite', 'rb')

model_file.readinto(hello_world_model)

model_file.close()

interp = microlite.interpreter(hello_world_model,2048, input_callback, output_callback)

print ("time step,y")
for c in range(steps):
    interp.invoke()
    counter = counter + 1
