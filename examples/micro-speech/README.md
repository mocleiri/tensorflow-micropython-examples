# Tensorflow Lite for Microcontrollers Micro Speech Example

The micro-speech example runs an example trained on the Speech Commands Version 2 Dataset.

It has been trained to detect four possible classes of output, each with a score:

```C
const int kSilenceIndex = 0;
const int kUnknownIndex = 1;
const int kYesIndex = 2;
const int kNoIndex = 3;
```

Scores above 200 are considered a match.

# ESP32 Port

The micropython firmware has miketeachman's code for the i2s for sampling audio using DMA.

The Audio is sampled then the *audio_frontend* module is used to create the spectrogram's that are fed into the tensorflow model.


# Unix Port

The code is the same but audio is encoded in arrays/binary data that needs to be processed.  The esp32/i2s_debug.py script can be used to 
save what you read from your mic into a wav file that can be used from the unix port.

# Upstream Example

This is the link to the micro_speech example in tensorflow

https://github.com/tensorflow/tensorflow/blob/master/tensorflow/lite/micro/examples/micro_speech/README.md
