# Tensorflow Lite for Microcontrollers in Micropython


# How to Build Tensorflow

```
make -f tensorflow/lite/micro/tools/make/Makefile  TARGET=esp32  TOOLCHAIN=xtensa-esp32-elf-gcc CXX
_TOOL=xtensa-esp32-elf-g++  CC_TOOL=xtensa-esp32-elf-gcc AR_TOOL=xtensa-esp32-elf-ar

```
 
# How to Build Micropython

```
make -f /src/src/GNUmakefile V=1 PART_SRC=/src/custom-partitions.csv MICROPY_PY_BLUETOOTH=0 M
ICROPY_BLUETOOTH_NIMBLE=0 MICROPY_BLUETOOTH_NIMBLE_BINDINGS_ONLY=0 CONFIG_ESP32_SPIRAM_SUPPORT=n all
```
# Flash image

ESP32D0WDQ6 4MB Flash

```

esptool.py --port COM5 erase_flash
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash -z 0x1000 esp32-20180511-v1.9.4.bin
```

# Credits

This firmware copied extensively from OpenMV.  Specifically starting from  

https://github.com/openmv/tensorflow-lib/blob/master/libtf.cc
and
https://github.com/openmv/tensorflow-lib/blob/master/libtf.h
