#!/bin/bash

# Pinned top-level dependency revisions for this repository.
# These checkouts live alongside the repo root and are managed by setup-deps.sh.

deps_list() {
cat <<'EOF'
micropython|micropython|https://github.com/micropython/micropython.git|9b486340da22931cde82872f79e1c34db959548b
micropython-ulab|micropython-ulab|https://github.com/v923z/micropython-ulab.git|57de23c1fb434ba99aaafe1d00bd77d5cdf5d66b
tensorflow|tensorflow|https://github.com/mocleiri/tflite-micro.git|626501f6010ce6e073bed0cdec70b692e5d38e11
tflm_esp_kernels|tflm_esp_kernels|https://github.com/espressif/tflite-micro-esp-examples.git|1987ce2e5ae7b518a0d0ca16fdecc1783460fd2b
EOF
}

readonly MICROPYTHON_COMMIT="9b486340da22931cde82872f79e1c34db959548b"
readonly MICROPYTHON_ULAB_COMMIT="57de23c1fb434ba99aaafe1d00bd77d5cdf5d66b"
readonly TENSORFLOW_COMMIT="626501f6010ce6e073bed0cdec70b692e5d38e11"
readonly TFLM_ESP_KERNELS_COMMIT="1987ce2e5ae7b518a0d0ca16fdecc1783460fd2b"
