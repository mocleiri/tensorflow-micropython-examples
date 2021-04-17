#
# Test for the micro_speech.py module
#
# When we debug micropython we can't debug the python part
# There is probably a better way to handle the imports being different in micropython vs regular python
#
# for now we just copy the actual code from micro_speech.py into here with native python imports and then the
# tests are below
#
# In native python we don't have access to tensorflow and also don't have access to the audio front-end.
import math

import numpy as np

# -- start of micro_speech.py

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
        # self.segment = segment
        if segment.size != 480:
            raise ValueError ("Expected segment to be 480 bytes, was %d." % (segment.size()))

        self.spectrogram = None
        self.start_index = start_index

    def getSpectrogram(self):
        return self.spectrogram

class FeatureData:

    def __init__(self):
        self.slices=[]
        self.totalSlices = 0

    def addSlice(self, slice):

        self.totalSlices = self.totalSlices + 1

        self.slices.append(slice)

        if len (self.slices) > 49:
            self.slices.pop(0)

        # print ("total slices = %d\n" % self.totalSlices)
        # print ("addSlice(): spectrogram length = %d\n" % spectrogram.size())
        # print (spectrogram)


    def setInputTensorValues(self, inputTensor):

        # print (inputTensor)

        counter = 0

        for slice_index in range(len(self.slices)):

            slice = self.slices[slice_index]

            spectrogram = slice.getSpectrogram()

            for spectrogram_index in range (spectrogram.size()):

                inputTensor.setValue(counter, spectrogram[spectrogram_index])
                counter = counter + 1



        # set 1960 values on input tensor
        # print ("set %d values on input tensor\n" % (counter))

def segmentAudio(featureData, audio, trailing_10ms):
    # In this example we have an array of 1 second of audio data.
    # This is a 16,000 element array.
    # each micro second is 16 elements in this array.
    # the stride is how far over we adjust the start of the window on each step
    # in this example it is 20 ms (20x16=320).
    # The width of the window for which we capture the spectogram is 30ms (16x30=480).
    # this function will turn the input array into a dictionary of start time to wav data


    input_audio = np.concatenate((trailing_10ms, audio), axis=0)

    input_size = input_audio.size

    total_segments = math.floor(input_size / stride_size)

    start_index = 0

    for segment_index in range (total_segments):

        end_index = min (start_index +  window_size, input_size)

        print ("segment_index=%d,start_index=%d, end_index=%d, size=%d\n" % (segment_index, start_index, end_index, end_index-start_index))

        slice = Slice (input_audio[start_index:end_index], start_index)

        featureData.addSlice(slice)

        start_index = start_index + stride_size

    # return the trailing 10ms
    return np.array(input_audio[input_size-160:input_size], dtype=np.int16)

# -- end of micro_speech.py

no_data = open ('no-example.wav', 'rb')

no_buffer = no_data.read()

no_data.close()

no_array = np.frombuffer(no_buffer[44:], dtype=np.int16)

inputBufferSize = 320*4

inputBuffer = bytearray(inputBufferSize)

trailing_10ms = np.zeros(160, dtype=np.int16)

count = no_array.size

start_index = 0


featureData = FeatureData()

class Score:

    def __init__(self, kind, score):
        self.kind = kind
        self.score = score

class Results:
    
    def __init__(self):
        self.silence_data = []
        self.unknown_data = []
        self.yes_data = []
        self.no_data  = []

        self.index = 0

    def _computeAverageTotal (self, array_data):
        total = 0

        array_length = len(array_data)

        for i in range (array_length):
            total = total + array_data[i]

        return math.floor(total / array_length)

    def computeResults(self):

        topScore = 0
        topScoreKind = None

        silence = self._computeAverageTotal(self.silence_data)

        if silence > 200:
            topScoreKind = "silence"
            topScore = silence

        unknown = self._computeAverageTotal(self.unknown_data)

        if unknown > topScore and unknown > 200:
            topScoreKind = "unknown"
            topScore = unknown

        yes = self._computeAverageTotal(self.yes_data)

        if yes > topScore and yes > 200:
            topScoreKind = "yes"
            topScore = yes

        no = self._computeAverageTotal(self.no_data)

        if no > topScore and no > 200:
            topScoreKind = "no"
            topScore = no

        return Score (topScoreKind, topScore)


    def storeResults(self, silenceScore, unknownScore, yesScore, noScore):

        if self.index == 3:
            self.silence_data.pop(0)
            self.unknown_data.pop(0)
            self.yes_data.pop(0)
            self.no_data.pop(0)
        else:
            self.index = self.index + 1

        self.silence_data.append(silenceScore)
        self.unknown_data.append(unknownScore)
        self.yes_data.append(yesScore)
        self.no_data.append(noScore)



kSilenceIndex = 0
kUnknownIndex = 1
kYesIndex = 2
kNoIndex = 3

r = Results()

r.storeResults(0, 0, 201, 0)

score = r.computeResults()

r.storeResults(0, 201, 0, 0)

score = r.computeResults()

while count > 0:
    # segment the 16000 element array into 320*4 parts
    currentStartIndex = start_index
    currentEndIndex = currentStartIndex + inputBufferSize

    currentSamples = np.array(no_array[currentStartIndex:currentEndIndex], dtype=np.int16)

    trailing_10ms = segmentAudio(featureData, currentSamples, trailing_10ms)

    start_index = currentEndIndex
    count = count - inputBufferSize

