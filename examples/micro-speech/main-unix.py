#
# For microspeech in unix we need to use a wav sample to invoke the tensorflow model
import no_1000ms_sample_data
import audio_frontend
from ulab import numpy as np

wav_input = no_1000ms_sample_data.no_1000ms_array

audio_frontend.configure()

output = audio_frontend.execute(wav_input)

print (output)


