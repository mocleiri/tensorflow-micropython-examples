from machine import I2S
from machine import Pin

bck_pin = Pin(18)  # Bit clock output
ws_pin = Pin(18)   # Word clock output
sdin_pin = Pin(5) # Serial data input

audio_in = I2S(I2S.NUM0,                                 # create I2S peripheral to read audio
               bck=bck_pin, ws=ws_pin, sdin=sdin_pin,    # sample data from an INMP441
               standard=I2S.PHILIPS, mode=I2S.MASTER_RX, # microphone module
               dataformat=I2S.B32,
               channelformat=I2S.RIGHT_LEFT,
               samplerate=16000,
               dmacount=16,dmalen=256)

samples = bytearray(2048)                                # bytearray to receive audio samples

num_bytes_read = audio_in.readinto(samples)              # read audio samples from microphone
# note:  blocks until sample array is full
# - see optional timeout argument
# to configure maximum blocking duration
