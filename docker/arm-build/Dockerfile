FROM debian:unstable-slim

RUN apt-get update && apt-get install -y python3 python3-pip

RUN apt-get update && apt-get install -y vim wget unzip git

RUN apt-get update && apt-get install -y curl

RUN pip install Pillow

#RUN cd /tmp && wget --no-verbose https://adafruit-circuit-python.s3.amazonaws.com/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 
#RUN tar -C /usr --strip-components=1 -xaf /tmp/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2

RUN pip install mbed-cli
