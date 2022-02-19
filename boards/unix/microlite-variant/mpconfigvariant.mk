# This is the default variant when you `make` the Unix port.

PROG ?= micropython

USER_C_MODULES=../../../micropython-modules

MICROPY_PY_FFI=0 

LDFLAGS_EXTRA=-static 

CFLAGS_EXTRA=-Wno-error=unused-function -Wno-error=maybe-uninitialized 

# -DMICROLITE_TFLM_OPS_CONFIG_FILE="tflm_ops.h"
# CXXFLAGS=-DMICROLITE_TFLM_OPS_CONFIG_FILE="tflm_ops.h"


