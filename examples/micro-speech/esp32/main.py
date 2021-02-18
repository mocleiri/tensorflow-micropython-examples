# The MIT License (MIT)
# Copyright (c) 2019 Michael Shi
# Copyright (c) 2020 Mike Teachman
# https://opensource.org/licenses/MIT

# Purpose:
# - read 32-bit audio samples from the left channel of an I2S microphone
# - snip upper 16-bits from each 32-bit microphone sample
# - write 16-bit samples to an internal flash file using WAV format
#
# Recorded WAV file is named:
#   "mic_left_channel_16bits.wav"
#
# Hardware tested:
# - INMP441 microphone module 
# - MSM261S4030H0 microphone module
#
# Notes:
# - writing audio sample data to internal flash is slow.  Gapless recordings require low sample rates (e.g.  8000 samples/second)
# - reading WAV files from internal flash to a PC:
#    - for short WAV files the AMPY tool can be used (e.g. 2 seconds @ 8000/samples).  Ampy throws an exception for long files
#    - for longer WAV files use the "Get a file" feature of the WebREPL.  

import audio_frontend
from ulab import numpy as np
import microlite
import model
from machine import Pin
from machine import I2S
import ucollections

#======= USER CONFIGURATION =======
SAMPLE_RATE_IN_HZ = 16000
#======= USER CONFIGURATION =======

WAV_SAMPLE_SIZE_IN_BITS = 16
WAV_SAMPLE_SIZE_IN_BYTES = WAV_SAMPLE_SIZE_IN_BITS // 8
MIC_SAMPLE_BUFFER_SIZE_IN_BYTES = 4096
SDCARD_SAMPLE_BUFFER_SIZE_IN_BYTES = MIC_SAMPLE_BUFFER_SIZE_IN_BYTES // 2 # why divide by 2? only using 16-bits of 32-bit samples
NUM_SAMPLES_IN_DMA_BUFFER = 320
NUM_CHANNELS = 1

# snip_16_mono():  snip 16-bit samples from a 32-bit mono sample stream
# assumption: I2S configuration for mono microphone.  e.g. I2S channelformat = ONLY_LEFT or ONLY_RIGHT
# example snip:  
#   samples_in[] =  [0x44, 0x55, 0xAB, 0x77, 0x99, 0xBB, 0x11, 0x22]             
#   samples_out[] = [0xAB, 0x77, 0x11, 0x22]
#   notes:
#       samples_in[] arranged in little endian format:  
#           0x77 is the most significant byte of the 32-bit sample
#           0x44 is the least significant byte of the 32-bit sample
#
# returns:  number of bytes snipped
def snip_16_mono(samples_in, samples_out):
    num_samples = len(samples_in) // 4
    for i in range(num_samples):
        samples_out[2*i] = samples_in[4*i + 2]
        samples_out[2*i + 1] = samples_in[4*i + 3]
            
    return num_samples * 2

bck_pin = Pin(19)
ws_pin = Pin(18)
sdin_pin = Pin(5)

audio_in = I2S(
    I2S.NUM0, 
    bck=bck_pin, ws=ws_pin, sdin=sdin_pin,
    standard=I2S.PHILIPS, 
    mode=I2S.MASTER_RX,
    dataformat=I2S.B32,
    channelformat=I2S.ONLY_RIGHT,
    samplerate=SAMPLE_RATE_IN_HZ,
    dmacount=16,
    dmalen=NUM_SAMPLES_IN_DMA_BUFFER
)

# wav = open('mic_left_channel_16bits.wav','wb')

# create header for WAV file and write to SD card
# wav_header = create_wav_header(
#     SAMPLE_RATE_IN_HZ,
#     WAV_SAMPLE_SIZE_IN_BITS,
#     NUM_CHANNELS,
#     SAMPLE_RATE_IN_HZ * RECORD_TIME_IN_SECONDS
# )
# num_bytes_written = wav.write(wav_header)


# The size of the input time series data we pass to the FFT to produce the
# frequency information. This has to be a power of two, and since we're dealing
# with 30ms of 16KHz inputs, which means 480 samples, this is the next value.
kMaxAudioSampleSize = 512
kAudioSampleFrequency = WAV_SAMPLE_SIZE_IN_BYTES

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
        if segment.size() != 480:
            raise ValueError ("Expected segment to be 480 bytes.")

        self.spectrogram = audio_frontend.execute(self.segment)
        self.start_index = start_index

    def getSpectrogram(self):
        return self.spectrogram

class FeatureData:

    def __init__(self):
        self.slices=[]
        self.last_10ms_audio = np.zeros(160)

    def addSlice(self, slice, last_10ms_audio):
        self.last_10ms_audio = np.array(last_10ms_audio, dtype=np.int16)

        self.slices.append(slice)

        spectrogram = slice.getSpectrogram()

        if len (self.slices) > 49:
            self.slices.pop(0)

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

# allocate sample arrays
#   memoryview used to reduce heap allocation in while loop
mic_samples = bytearray(MIC_SAMPLE_BUFFER_SIZE_IN_BYTES)
mic_samples_mv = memoryview(mic_samples)

one_second_data = np.zeros(16000)
# trailing_10ms = np.zeros(160)

# ucollections.deque(maxlen=16000)

num_sample_bytes_written_to_wav = 0

print('Starting')
# read 32-bit samples from I2S microphone, snip upper 16-bits, write snipped samples to WAV file
while True:
    try:
        # try to read a block of samples from the I2S microphone
        # readinto() method returns 0 if no DMA buffer is full
        num_bytes_read_from_mic = audio_in.readinto(mic_samples_mv, timeout=0)
        if num_bytes_read_from_mic > 0:
            # shift these number of bytes off the front of the one_second_data array
            # append the int16 data
            print ("read %d bytes into the mic_samples_mv buffer\n" % num_bytes_read_from_mic)
            # snip upper 16-bits from each 32-bit microphone sample
            # num_bytes_snipped = snip_16_mono(mic_samples_mv[:num_bytes_read_from_mic], wav_samples_mv)
            # num_bytes_to_write = min(num_bytes_snipped, NUM_SAMPLE_BYTES_TO_WRITE - num_sample_bytes_written_to_wav)
            # write samples to WAV file
            # num_bytes_written = wav.write(wav_samples_mv[:num_bytes_to_write])
            # num_sample_bytes_written_to_wav += num_bytes_written

    except (KeyboardInterrupt, Exception) as e:
        print('caught exception {} {}'.format(type(e).__name__, e))
        break

audio_in.deinit()
print('Done')
print('%d sample bytes written to WAV file' % num_sample_bytes_written_to_wav)
