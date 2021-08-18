# Tensorflow Lite for Microcontrollers Micro Speech Example

The micro-speech example runs an example trained on the Speech Commands Version 2 Dataset.

Scores above 200 are considered a match.

# Model Architecture

![](images/model_architecture.png)

It has been trained to detect four possible classes of output, each with a score:

```C
const int kSilenceIndex = 0;
const int kUnknownIndex = 1;
const int kYesIndex = 2;
const int kNoIndex = 3;
```

# Audio Preprocessing

![spectrogram diagram](https://storage.googleapis.com/download.tensorflow.org/example_images/spectrogram_diagram.png)

The audio_frontend micropython module is used to wrap the tensorflow lite experimental audio_frontend
which contains the logic to convert a 30 milli-second sample into a spectrogram that can be fed into
the input layer of the model.

# ESP32 Port

For a real example you will want to create an machine.I2S object from a MEM's microphone to:
1. sample audio
2. convert audio into spectrogram
3. run inference on model
4. do something with the predicted results.

The Audio is sampled then the *audio_frontend* module is used to create the spectrogram's that are fed into the tensorflow model.

# Unix Port

The code is the same but audio is encoded in arrays/binary data that needs to be processed.  The esp32/i2s_debug.py script can be used to 
save what you read from your mic into a wav file that can be used from the unix port.

# Tensorflow Micro C++ Micro_Speech Example

This is the link to the [micro_speech example](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/examples/micro_speech/README.md) in tensorflow micro

