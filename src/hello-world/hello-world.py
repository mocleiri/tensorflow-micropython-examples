import microlite

counter = 1

kXrange = 2.0 * 3.14159265359

def input_callback (microlite_interpreter, input_tensor):
    print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    position = (counter*1.0) / 1.0

    print ("position %f" % position)

    x = position * kXrange

    print ("x: %f" % x)

    input_tensor.data.f[0] = x

    print ("input tensor data: %f", input_tensor.data.f[0])


def output_callback (microlite_interpreter, output_tensor):
    print ("output callback")
    # print (output_tensor)

interp = microlite.interpreter(2048, input_callback, output_callback)

interp.invoke()