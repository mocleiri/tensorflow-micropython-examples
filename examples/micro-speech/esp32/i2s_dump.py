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

from machine import Pin
from machine import I2S

#======= USER CONFIGURATION =======
RECORD_TIME_IN_SECONDS = 2
SAMPLE_RATE_IN_HZ = 16000
#======= USER CONFIGURATION =======

WAV_SAMPLE_SIZE_IN_BITS = 16
WAV_SAMPLE_SIZE_IN_BYTES = WAV_SAMPLE_SIZE_IN_BITS // 8
MIC_SAMPLE_BUFFER_SIZE_IN_BYTES = 4096
SDCARD_SAMPLE_BUFFER_SIZE_IN_BYTES = MIC_SAMPLE_BUFFER_SIZE_IN_BYTES // 2 # why divide by 2? only using 16-bits of 32-bit samples
NUM_SAMPLE_BYTES_TO_WRITE = RECORD_TIME_IN_SECONDS * SAMPLE_RATE_IN_HZ * WAV_SAMPLE_SIZE_IN_BYTES
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

def create_wav_header(sampleRate, bitsPerSample, num_channels, num_samples):
    datasize = num_samples * num_channels * bitsPerSample // 8
    o = bytes("RIFF",'ascii')                                                   # (4byte) Marks file as RIFF
    o += (datasize + 36).to_bytes(4,'little')                                   # (4byte) File size in bytes excluding this and RIFF marker
    o += bytes("WAVE",'ascii')                                                  # (4byte) File type
    o += bytes("fmt ",'ascii')                                                  # (4byte) Format Chunk Marker
    o += (16).to_bytes(4,'little')                                              # (4byte) Length of above format data
    o += (1).to_bytes(2,'little')                                               # (2byte) Format type (1 - PCM)
    o += (num_channels).to_bytes(2,'little')                                    # (2byte)
    o += (sampleRate).to_bytes(4,'little')                                      # (4byte)
    o += (sampleRate * num_channels * bitsPerSample // 8).to_bytes(4,'little')  # (4byte)
    o += (num_channels * bitsPerSample // 8).to_bytes(2,'little')               # (2byte)
    o += (bitsPerSample).to_bytes(2,'little')                                   # (2byte)
    o += bytes("data",'ascii')                                                  # (4byte) Data Chunk Marker
    o += (datasize).to_bytes(4,'little')                                        # (4byte) Data size in bytes
    return o

# change pins based on how you have wired up the microphone
# Green Wire
bck_pin = Pin(19)
# Yellow Wire
ws_pin = Pin(18)
# Purple Wire
sdin_pin = Pin(23)

audio_in = I2S(0,
               sck=bck_pin,
               ws=ws_pin,
               sd=sdin_pin,
               mode=I2S.RX,
               bits=16,
               format=I2S.MONO,
               rate=16000,
               ibuf=16000
               )

wav = open('mic_left_channel_16bits.wav','wb')

# create header for WAV file and write to SD card
wav_header = create_wav_header(
    SAMPLE_RATE_IN_HZ,
    WAV_SAMPLE_SIZE_IN_BITS,
    NUM_CHANNELS,
    SAMPLE_RATE_IN_HZ * RECORD_TIME_IN_SECONDS
)
num_bytes_written = wav.write(wav_header)

# allocate sample arrays
#   memoryview used to reduce heap allocation in while loop

# 2 second buffer
mic_samples = bytearray(6400)
mic_samples_mv = memoryview(mic_samples)

num_sample_bytes_written_to_wav = 0

print('Starting')
# read 32-bit samples from I2S microphone, snip upper 16-bits, write snipped samples to WAV file
while num_sample_bytes_written_to_wav < 64000:
    try:
        # try to read a block of samples from the I2S microphone
        # readinto() method returns 0 if no DMA buffer is full
        num_bytes_read_from_mic = audio_in.readinto(mic_samples_mv)

        if num_bytes_read_from_mic > 0:
            # snip upper 16-bits from each 32-bit microphone sample

            print('%d sample bytes read from i2s' % num_bytes_read_from_mic)

            # num_bytes_snipped = snip_16_mono(mic_samples_mv[:num_bytes_read_from_mic], wav_samples_mv)
            # num_bytes_to_write = min(num_bytes_snipped, NUM_SAMPLE_BYTES_TO_WRITE - num_sample_bytes_written_to_wav)
            # write samples to WAV file
            num_bytes_written = wav.write(mic_samples_mv[:num_bytes_read_from_mic])

            num_sample_bytes_written_to_wav += num_bytes_written
    except (KeyboardInterrupt, Exception) as e:
        print('caught exception {} {}'.format(type(e).__name__, e))
        break

wav.close()

audio_in.deinit()

print('%d sample bytes written to WAV file' % num_sample_bytes_written_to_wav)

# now make the spectrograms

print('Done')

