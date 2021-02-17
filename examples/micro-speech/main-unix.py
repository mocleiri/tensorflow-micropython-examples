#
# For microspeech in unix we need to use a wav sample to invoke the tensorflow model
import no_1000ms_sample_data
import yes_1000ms_sample_data
import audio_frontend
from ulab import numpy as np
import microlite
import model;

# The size of the input time series data we pass to the FFT to produce the
# frequency information. This has to be a power of two, and since we're dealing
# with 30ms of 16KHz inputs, which means 480 samples, this is the next value.
kMaxAudioSampleSize = 512
kAudioSampleFrequency = 16000

kAudioOneMsSize = 16

# The following values are derived from values used during model training.
# If you change the way you preprocess the input, update all these constants.
kFeatureSliceSize = 40
kFeatureSliceCount = 49
kFeatureElementCount = (kFeatureSliceSize * kFeatureSliceCount)
kFeatureSliceStrideMs = 20
kFeatureSliceDurationMs = 30

stride_size = kFeatureSliceStrideMs * kAudioOneMsSize

window_size = kFeatureSliceDurationMs * kAudioOneMsSize

class Slice:

    def __init__(self, segment, start_index):
        self.segment = segment
        self.spectrogram = audio_frontend.execute(self.segment)
        self.start_index = start_index

    def getSpectrogram(self):
        return self.spectrogram
        
class FeatureData:
    
    def __init__(self):
        self.slices=[]

    def addSlice(self, slice):
        self.slices.append(slice)

        spectrogram = slice.getSpectrogram()

        # print ("addSlice(): slice length = %d\n" % slice.segment.size())
        # print ("addSlice(): spectrogram length = %d\n" % spectrogram.size())
        

    def setInputTensorValues(self, inputTensor):

        counter = 0

        for slice_index in range(len(self.slices)):

            slice = self.slices[slice_index]

            spectrogram = slice.getSpectrogram()

            for spectrogram_index in range (spectrogram.size()):

                inputTensor.setValue(counter, spectrogram[spectrogram_index])
                counter = counter + 1


        


def segmentAudio(audio):
    # In this example we have an array of 1 second of audio data.
    # This is a 16,000 element array.
    # each micro second is 16 elements in this array.
    # the stride is how far over we adjust the start of the window on each step
    # in this example it is 20 ms (20x16=320).
    # The width of the window for which we capture the spectogram is 30ms (16x30=480).
    # this function will turn the input array into a dictionary of start time to wav data

    featureData = FeatureData()

    input_size = audio.size()

    total_segments = input_size / stride_size

    start_index = 0

    for segment_index in range (total_segments):

        end_index = min (start_index +  window_size, input_size)

        print ("segment_index=%d,start_index=%d, end_index=%d, size=%d\n" % (segment_index, start_index, end_index, end_index-start_index))

        slice = Slice (audio[start_index:end_index], start_index)

        featureData.addSlice(slice)

        start_index = start_index + stride_size

    return featureData


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


interp = microlite.interpreter(model.micro_speech_model,20480, input_callback, output_callback)


no_pcm_input = no_1000ms_sample_data.no_1000ms_array

print ("length of no input = %d\n" % (len (no_pcm_input)))


noFeatureData = segmentAudio(no_pcm_input)

currentFeatureData = noFeatureData

interp.invoke()

foundIndex = maxIndex()

if foundIndex != kNoIndex:
    raise ValueError("Error: Expected inference to match the 1 second no sample to no.\n")


yes_pcm_input = yes_1000ms_sample_data.yes_1000ms_array

print ("length of yes input = %d\n" % (len (yes_pcm_input)))

yesFeatureData = segmentAudio(yes_pcm_input)

currentFeatureData = yesFeatureData

interp.invoke()

foundIndex = maxIndex()

if foundIndex != kYesIndex:
    raise ValueError("Error: Expected inference to match the 1 second yes sample to yes.\n")




