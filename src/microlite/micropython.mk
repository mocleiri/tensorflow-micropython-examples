MICROLITE_MOD_DIR := $(USERMOD_DIR)

# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(MICROLITE_MOD_DIR)/tensorflow-microlite.c

SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/openmv-libtf.cpp
SRC_USERMOD_CXX += $(MICROLITE_MOD_DIR)/hello-world-model.cpp


# needed with c++
LDFLAGS_USERMOD += -lstdc++

# this path is valid if used within the esp-idf-4.0.1 docker container
LDFLAGS_USERMOD += /src/lib/libtensorflow-microlite.a

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)

CFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow

CFLAGS_USERMOD += -Wno-error=discarded-qualifiers

CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow
CXXFLAGS_USERMOD += -I$(MICROLITE_MOD_DIR)/../../tensorflow/tensorflow/lite/micro/tools/make/downloads/flatbuffers/include
CXXFLAGS_USERMOD += -Wno-error=sign-compare


override CFLAGS_EXTRA += -DMODULE_MICROLITE_ENABLED=1

PART_SRC=partitions-2MiB.csv
