#
# For microspeech in unix we need to use a wav sample to invoke the tensorflow model
import audio_frontend
import micro_speech
from ulab import numpy as np
import microlite
import io
import no_1000ms_sample_data
import yes_1000ms_sample_data


micro_speech_model = bytearray(18288)

model_file = io.open('model.tflite', 'rb')

model_file.readinto(micro_speech_model)

model_file.close()

currentFeatureData = None

def input_callback (microlite_interpreter):

    # print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    inputTensor = microlite_interpreter.getInputTensor(0)

    currentFeatureData.setInputTensorValues(inputTensor)

    

kSilenceIndex = 0
kUnknownIndex = 1
kYesIndex = 2
kNoIndex = 3

inferenceResult = {}

def maxIndex ():

    maxValue = 0
    maxIndex = 0

    for index in range (4):
        value = inferenceResult[index]

        if (value > maxValue):
            maxValue = value
            maxIndex = index

    print ("maxIndex=%d,maxValue=%d\n" %(maxIndex, maxValue))

    return maxIndex

def output_callback (microlite_interpreter):
    # print ("output callback")

    outputTensor = microlite_interpreter.getOutputTensor(0)

    # we expect there to be a category

    for index in range (4):
        result = outputTensor.getValue(index)
        print ("results at %d = result = %d\n" % (index, result))
        inferenceResult[index] = result



audio_frontend.configure()


interp = microlite.interpreter(micro_speech_model,20480, input_callback, output_callback)


no_pcm_input = no_1000ms_sample_data.no_1000ms_array

print ("length of no input = %d\n" % (len (no_pcm_input)))

noFeatureData = micro_speech.FeatureData(interp)

trailing_10ms = np.zeros(160, dtype=np.int16)

trailing_10ms = micro_speech.segmentAudio(noFeatureData, no_pcm_input, trailing_10ms)

currentFeatureData = noFeatureData

interp.invoke()

foundIndex = maxIndex()

if foundIndex != kNoIndex:
    raise ValueError("Error: Expected inference to match the 1 second no sample to no.\n")


yes_pcm_input = yes_1000ms_sample_data.yes_1000ms_array

print ("length of yes input = %d\n" % (len (yes_pcm_input)))

yesFeatureData = micro_speech.FeatureData(interp)

trailing_10ms = np.zeros(160, dtype=np.int16)

micro_speech.segmentAudio(yesFeatureData, yes_pcm_input, trailing_10ms)

currentFeatureData = yesFeatureData

interp.invoke()

foundIndex = maxIndex()

if foundIndex != kYesIndex:
    raise ValueError("Error: Expected inference to match the 1 second yes sample to yes.\n")




