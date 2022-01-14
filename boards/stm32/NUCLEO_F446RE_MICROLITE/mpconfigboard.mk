include boards/NUCLEO_F446RE/mpconfigboard.mk

USER_C_MODULES=../../../micropython-modules

FROZEN_MANIFEST =  $(BOARD_DIR)/manifest.py

# VFS FAT FS support
MICROPY_VFS_FAT = 0

# TODO: consider adding a flag upstream to not link part of libm
# especially since for microlite we are linking libm anyways.
# LINKING_LIBM = 0