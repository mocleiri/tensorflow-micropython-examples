# Customized ESP-IDF Docker Environment

First we need a base docker image for esp-idf at version 4.0.1 which is what Micropython currently needs.

Then we need to add some extra bits to the image needed for compiling tensorflow and related example parts.

## Build ESP-IDF Docker Environment


Build base esp-idf 4.0.1 Docker image:
1. Checkout the latest [esp-idf](https://github.com/espressif/esp-idf) then go into **tools/docker**.
2. docker build -t espressif-idf-v4.0.1 --build-arg IDF_CHECKOUT_REF=4c81978a3e2220674a432a588292a4c860eef27b .

This is the 4.0.1 version that micropython wants.  I have done the above steps and put the resultant image into dockerhub here:
https://hub.docker.com/r/mocleiri/esp-idf-4.0.1

## Build customized esp32 Docker Environment

```
$ docker build -t esp-idf-4.0.1-builder .
```
