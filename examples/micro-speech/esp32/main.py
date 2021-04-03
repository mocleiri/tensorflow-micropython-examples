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
sdin_pin = Pin(23)

audio_in = I2S(
    I2S.NUM0,
    bck=bck_pin, ws=ws_pin, sdin=sdin_pin,
    standard=I2S.PHILIPS,
    mode=I2S.MASTER_RX,
    dataformat=I2S.B16,
    channelformat=I2S.ONLY_RIGHT,
    samplerate=SAMPLE_RATE_IN_HZ,
    dmacount=50,
    dmalen=320
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




featureData = micro_speech.FeatureData()

def input_callback (microlite_interpreter):

    # print ("input callback")
    # can't print the tensor directly because it is not an mp_obj_t
    # we probably need to define a container object that will hold the TfLiteTensor pointer
    # we may be able to put the pointer directly as a field in the interpreter class
    # print (input_tensor)

    inputTensor = microlite_interpreter.getInputTensor(0)

    featureData.setInputTensorValues(inputTensor)



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

    # print ("maxIndex=%d,maxValue=%d\n" %(maxIndex, maxValue))

    return maxIndex

def output_callback (microlite_interpreter):
    # print ("output callback")

    outputTensor = microlite_interpreter.getOutputTensor(0)

    # we expect there to be a category

    for index in range (4):
        result = outputTensor.getValue(index)
        # print ("results at %d = result = %d\n" % (index, result))
        inferenceResult[index] = result


interp = microlite.interpreter(micro_speech_model,8 * 1024, input_callback, output_callback)

# allocate sample arrays
#   memoryview used to reduce heap allocation in while loop
# 320 x 4
mic_samples = bytearray(320*4)
mic_samples_mv = memoryview(mic_samples)


#int16_samples = bytearray(640)
#int16_samples_mv = memoryview(int16_samples)

trailing_10ms = np.zeros(160, dtype=np.int16)



# one_second_data = np.zeros(16000)
# trailing_10ms = np.zeros(160)

# ucollections.deque(maxlen=16000)

num_sample_bytes_written_to_wav = 0

print('Starting')
# read 32-bit samples from I2S microphone, snip upper 16-bits, write snipped samples to WAV file
while True:
    try:
        # try to read a block of samples from the I2S microphone
        # readinto() method returns 0 if no DMA buffer is full
        num_bytes_read_from_mic = audio_in.readinto(mic_samples_mv)

        if num_bytes_read_from_mic > 0:
            # shift these number of bytes off the front of the one_second_data array
            # append the int16 data


            # num_bytes_snipped = snip_16_mono(mic_samples_mv[:num_bytes_read_from_mic], int16_samples_mv)

            # print ("read %d bytes into the mic_samples_mv buffer\n" % num_bytes_read_from_mic)
            # print ("read %d bytes into the int16_samples_mv buffer\n" % num_bytes_snipped)
            audio_samples = np.frombuffer(mic_samples_mv, dtype=np.int16)

            trailing_10ms = segmentAudio(featureData, audio_samples, trailing_10ms)

        interp.invoke()

        foundIndex = maxIndex()

        print ("found index - %d\n" % foundIndex)

    except (KeyboardInterrupt, Exception) as e:
        print('caught exception {} {}'.format(type(e).__name__, e))
        break

audio_in.deinit()
print('Done')
print('%d sample bytes written to WAV file' % num_sample_bytes_written_to_wav)


