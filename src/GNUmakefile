# expects to be called from esp-idf docker container
ESPIDF ?= /opt/esp/idf
BOARD ?= GENERIC
#PORT ?= /dev/ttyUSB0
#FLASH_MODE ?= qio
#FLASH_SIZE ?= 4MB
CROSS_COMPILE ?= xtensa-esp32-elf-
PYTHON2 = python3
USER_C_MODULES=../../../src
CFLAGS_EXTRA=-DMODULE_MICROLITE_ENABLED=1

include Makefile
