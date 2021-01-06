MICROLITE_MOD_DIR := $(USERMOD_DIR)

# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tensorflow-microlite.c

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/hello-world-model.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/hello-world-interpreter.cpp


# needed with c++
LDFLAGS_USERMOD += -lstdc++
LDFLAGS_USERMOD += $(MICROLITE_MOD_DIR)/../../lib/libtensorflow-microlite.a

# We can add our module folder to include paths if needed
# This is not actually needed in this example.
CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow/tensorflow/lite/micro/tools/make/downloads/flatbuffers/include
CXXFLAGS_USERMOD += -Wno-error=sign-compare


override CFLAGS_EXTRA += -DMODULE_MICROLITE_ENABLED=1
