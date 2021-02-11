#
# For microspeech in unix we need to use a wav sample to invoke the tensorflow model
import no_1000ms_sample_data
import audio_frontend
from ulab import numpy as np
import microlite
import model;

wav_input = no_1000ms_sample_data.no_1000ms_array

print ("length of wav input = %d\n" % (len (wav_input)))
audio_frontend.configure()

startIndex = 0
audioSampleIndex = 0

kFeatureElementCount = 1960
#  The size of the input time series data we pass to the FFT to produce the
#  frequency information. This has to be a power of two, and since we're dealing
#  with 30ms of 16KHz inputs, which means 480 samples, this is the next value.
kMaxAudioSampleSize = 512

spectogramSamples = {}

def processAudio():
    # we need to consume the 
    global startIndex
    global audioSampleIndex

    endIndex = startIndex + kMaxAudioSampleSize

    if endIndex > wav_input.size():
        return False

    output = audio_frontend.execute(wav_input[startIndex:endIndex])

    print ("output len = %d\n" % (output.size()))

    spectogramSamples[audioSampleIndex] = output

    audioSampleIndex += 1
    startIndex = endIndex

    return True




def input_callback (microlite_interpreter):

    # print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    inputTensor = microlite_interpreter.getInputTensor(0)

    counter = 0
    for index in range (audioSampleIndex):

        data = spectogramSamples[index]

        for dataIndex in range (data.size()):
            value = data[dataIndex]
            inputTensor.setValue(counter, value)
            counter += 1

def output_callback (microlite_interpreter):
    # print ("output callback")

    outputTensor = microlite_interpreter.getOutputTensor(0)

    # we expect there to be a category

    for index in range (4):
        result = outputTensor.getValue(index)
        print ("results at %d = result = %d" % (index, result))


while processAudio() == True:
    pass

interp = microlite.interpreter(model.micro_speech_model,20480, input_callback, output_callback)

interp.invoke()



