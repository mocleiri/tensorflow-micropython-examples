# Makefile for custom MicroPython stm32 board.

################################################################################
# Define your settings here.

# The board name.
BOARD ?= NUCLEO_H743ZI2_MICROLITE

# Location of MicroPython repository.
MICROPY_TOP ?= $(abspath ../../../micropython)

################################################################################
# Define your targets here.

all: firmware

################################################################################
# Items below this line do not generally need to be changed.

BOARD_DIR ?= $(abspath .)
BUILD = $(BOARD_DIR)/build

include $(MICROPY_TOP)/py/mkenv.mk
include $(MICROPY_TOP)/py/mkrules.mk

firmware:
	$(Q)$(MAKE) -C $(MICROPY_TOP)/ports/stm32 \
		PROJECT_TOP=$(abspath ../..) \
		BOARD=$(BOARD) \
		BOARD_DIR=$(BOARD_DIR) \
		BUILD=$(BUILD)
		

deploy:
	$(PYTHON) $(MICROPY_TOP)/tools/pydfu.py -u $(BUILD)/firmware.dfu
