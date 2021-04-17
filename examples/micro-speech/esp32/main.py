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

import gc
import io
import audio_frontend
from ulab import numpy as np
import micro_speech
import microlite
import utime
from machine import Timer



from machine import Pin
from machine import I2S


micro_speech_model = bytearray(18288)

model_file = io.open('model.tflite', 'rb')

model_file.readinto(micro_speech_model)

model_file.close()

#======= USER CONFIGURATION =======
SAMPLE_RATE_IN_HZ = 16000
#======= USER CONFIGURATION =======

WAV_SAMPLE_SIZE_IN_BITS = 16
WAV_SAMPLE_SIZE_IN_BYTES = WAV_SAMPLE_SIZE_IN_BITS // 8
MIC_SAMPLE_BUFFER_SIZE_IN_BYTES = 4096
SDCARD_SAMPLE_BUFFER_SIZE_IN_BYTES = MIC_SAMPLE_BUFFER_SIZE_IN_BYTES // 2 # why divide by 2? only using 16-bits of 32-bit samples
NUM_SAMPLES_IN_DMA_BUFFER = 320
NUM_CHANNELS = 1

bck_pin = Pin(19)
ws_pin = Pin(18)
sdin_pin = Pin(23)

audio_in = I2S(
    I2S.NUM0,
    bck=bck_pin, ws=ws_pin, sdin=sdin_pin,
    standard=I2S.PHILIPS,
    mode=I2S.MASTER_RX,
    dataformat=I2S.B16,
    channelformat=I2S.ONLY_RIGHT,
    samplerate=16000,
    dmacount=20,
    dmalen=320
)


def input_callback (microlite_interpreter):

    # print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    inputTensor = microlite_interpreter.getInputTensor(0)

    featureData.setInputTensorValues(inputTensor)

totalSlices = 0

kSilenceIndex = 0
kUnknownIndex = 1
kYesIndex = 2
kNoIndex = 3

inferenceResult = {0:0, 1:0, 2:0, 3:0}

def maxIndex ():

    maxValue = 0
    maxIndex = 0

    for index in range (4):
        value = inferenceResult[index]

        if (value > maxValue):
            maxValue = value
            maxIndex = index

    print ("maxIndex=%d,maxValue=%d\n" %(maxIndex, maxValue))

    if maxValue > 180:
        return maxIndex
    else:
        return kUnknownIndex


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

results = Results()

def output_callback (microlite_interpreter):
    # print ("output callback")

    outputTensor = microlite_interpreter.getOutputTensor(0)

    # we expect there to be a category

    silence = outputTensor.getValue(kSilenceIndex)
    unknown = outputTensor.getValue(kUnknownIndex)
    yes     = outputTensor.getValue(kYesIndex)
    no      = outputTensor.getValue(kNoIndex)
    
    results.storeResults(silence, unknown, yes, no)
    
    
    
    
interp = microlite.interpreter(micro_speech_model,8 * 1024, input_callback, output_callback)

featureData = micro_speech.FeatureData(interp)

# allocate sample arrays
#   memoryview used to reduce heap allocation in while loop
# 320 x 4
mic_samples = bytearray(320*15*2)
mic_samples_mv = memoryview(mic_samples)


#int16_samples = bytearray(640)
#int16_samples_mv = memoryview(int16_samples)

trailing_10ms = np.zeros(160, dtype=np.int16)



# one_second_data = np.zeros(16000)
# trailing_10ms = np.zeros(160)

# ucollections.deque(maxlen=16000)

printPerSecondStats = False

def timerCallback(timer):
    global printPerSecondStats
    
    printPerSecondStats = True
    
tim0 = Timer(0)
tim0.init(period=1000, mode=Timer.PERIODIC, callback=timerCallback)

num_sample_bytes_written_to_wav = 0

bytesReadPerSecond = 0

inferences = 0

print('Starting')
# read 32-bit samples from I2S microphone, snip upper 16-bits, write snipped samples to WAV file
while True:
    try:
        
        gc.collect()
        if printPerSecondStats:
            print ("Total Bytes read last second = %d\n" % (bytesReadPerSecond))
            print ("Total Inferences last second = %d\n" % (inferences))
            printPerSecondStats = False
            bytesReadPerSecond = 0
            inferences = 0
        
        # try to read a block of samples from the I2S microphone
        # readinto() method returns 0 if no DMA buffer is full
        start = utime.ticks_ms()
        num_bytes_read_from_mic = audio_in.readinto(mic_samples_mv)

        after_read = utime.ticks_ms()
        
        bytesReadPerSecond = bytesReadPerSecond + num_bytes_read_from_mic
        
        if num_bytes_read_from_mic > 0:
            # shift these number of bytes off the front of the one_second_data array
            # append the int16 data


            # num_bytes_snipped = snip_16_mono(mic_samples_mv[:num_bytes_read_from_mic], int16_samples_mv)

            # print ("read %d bytes into the mic_samples_mv buffer\n" % num_bytes_read_from_mic)
            # print ("read %d bytes into the int16_samples_mv buffer\n" % num_bytes_snipped)
            audio_samples = np.frombuffer(mic_samples_mv, dtype=np.int16)

            # print ("read %d audio_samples = %d\n" % (num_bytes_read_from_mic, audio_samples.size()))

            trailing_10ms = micro_speech.segmentAudio(featureData, audio_samples, trailing_10ms)

            totalSlices = totalSlices + 8
            
            after_spectogram = utime.ticks_ms()
            
        interp.invoke()
        
        inferences = inferences + 1

        score = results.computeResults()
    
        if score.kind == "yes":
            found = "yes"
            print ("found - %s@%dms\n" % (found, totalSlices*480))
        elif score.kind == "no":
            found = "no"
            print ("found - %s@%dms\n" % (found, totalSlices*480))
    
        after_inference = utime.ticks_ms()
        
        # print ("total loop time = %d\n" %utime.ticks_diff(start, after_inference))
        
        # foundIndex = maxIndex()

        #print ("found index - %d\n" % foundIndex)

    except (KeyboardInterrupt, Exception) as e:
        print('caught exception {} {}'.format(type(e).__name__, e))
        break

audio_in.deinit()
tim0.deinit()
print('Done')
print('%d sample bytes written to WAV file' % num_sample_bytes_written_to_wav)





