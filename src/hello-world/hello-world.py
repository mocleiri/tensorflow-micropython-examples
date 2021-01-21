import microlite

counter = 1

kXrange = 2.0 * 3.14159265359

def input_callback (microlite_interpreter):
    print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    inputTensor = microlite_interpreter.getInputTensor(0)

    print (inputTensor)

    position = (counter*1.0) / 1.0

    # print ("position %f" % position)

    x = position * kXrange

    print ("x: %f" % x)

    x_quantized = inputTensor.quantizeFloatToInt8(x)

    inputTensor.setValue(0, x_quantized)

def output_callback (microlite_interpreter):
    print ("output callback")

    outputTensor = microlite_interpreter.getOutputTensor(0)

    print (outputTensor)

    y_quantized = outputTensor.getValue(0)
    
    y = outputTensor.quantizeInt8ToFloat(y_quantized)
    
    print ("y = %f" % y)



interp = microlite.interpreter(2048, input_callback, output_callback)

interp.invoke()