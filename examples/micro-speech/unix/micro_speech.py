import math

import microlite

from ulab import numpy as np

audio_frontend = microlite.audio_frontend()

audio_frontend.configure()

# The size of the input time series data we pass to the FFT to produce the
# frequency information. This has to be a power of two, and since we're dealing
# with 30ms of 16KHz inputs, which means 480 samples, this is the next value.
kMaxAudioSampleSize = const (512)
kAudioSampleFrequency = const (16000)

kAudioOneMsSize = const (16)

# The following values are derived from values used during model training.
# If you change the way you preprocess the input, update all these constants.
kFeatureSliceSize = const (40)
kFeatureSliceCount = const (49)
kFeatureElementCount = const(kFeatureSliceSize * kFeatureSliceCount)
kFeatureSliceStrideMs = const (20)
kFeatureSliceDurationMs = const (30)

stride_size = const (kFeatureSliceStrideMs * kAudioOneMsSize)

window_size = const (kFeatureSliceDurationMs * kAudioOneMsSize)

class Slice:

    def __init__(self, segment, start_index):
        # self.segment = segment
        if segment.size != 480:
            raise ValueError ("Expected segment to be 480 bytes, was %d." % (segment.size))

        self.spectrogram = audio_frontend.execute(segment)

        # print (self.spectrogram)

        self.start_index = start_index

    def getSpectrogram(self):
        return self.spectrogram

class FeatureData:

    def __init__(self, tf_interp):
        self.slices=[]
        self.totalSlices = 0
        self.tf_interp = tf_interp

    def addSlice(self, slice):

        self.totalSlices = self.totalSlices + 1

        self.slices.append(slice)

        if len (self.slices) > 49:
            self.slices.pop(0)


        # self.tf_interp.invoke()



        # print ("total slices = %d\n" % self.totalSlices)
        # print ("addSlice(): spectrogram length = %d\n" % spectrogram.size)
        # print (spectrogram)


    def reset(self):

        self.slices=[]
        self.totalSlices = 0



    def setInputTensorValues(self, inputTensor):

        # print (inputTensor)

        counter = 0

        for slice_index in range(len(self.slices)):

            slice = self.slices[slice_index]

            for spectrogram_index in range (slice.spectrogram.size):

                inputTensor.setValue(counter, slice.spectrogram[spectrogram_index])
                counter = counter + 1



        # set 1960 values on input tensor
        # print ("set %d values on input tensor\n" % (counter))
    def writeSpectogramValues(self, kind, file):

        # print (inputTensor)

        counter = 0

        file.write ("%s spectogram = [ " % (kind))

        for slice_index in range(len(self.slices)):

            slice = self.slices[slice_index]

            size = slice.spectrogram.size

            for spectrogram_index in range (size):

                file.write ("%d, " % (slice.spectrogram[spectrogram_index]))

        file.write (" ]\n")

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

        # print ("segment_index=%d,start_index=%d, end_index=%d, size=%d\n" % (segment_index, start_index, end_index, end_index-start_index))

        slice = Slice (input_audio[start_index:end_index], start_index)

        featureData.addSlice(slice)

        start_index = start_index + stride_size

    # return the trailing 10ms
    return np.array(input_audio[input_size-160:input_size], dtype=np.int16)


