#!/bin/bash

# Pinned top-level dependency revisions for this repository.
# These checkouts live alongside the repo root and are managed by setup-deps.sh.

deps_list() {
cat <<'EOF'
micropython|micropython|https://github.com/micropython/micropython.git|77427c8038f5f00c701ceac933fed969bc9143d6
micropython-ulab|micropython-ulab|https://github.com/v923z/micropython-ulab.git|a8b25eff3eea742b949012e512de7c69886e7794
tensorflow|tensorflow|https://github.com/tensorflow/tflite-micro.git|f5302ed4fa99b7ec697e578057a1f61445a442fe
tflm_esp_kernels|tflm_esp_kernels|https://github.com/espressif/tflite-micro-esp-examples.git|e06bd902394dfd7c21f14377623c157700431e43
EOF
}

readonly MICROPYTHON_COMMIT="77427c8038f5f00c701ceac933fed969bc9143d6"
readonly MICROPYTHON_ULAB_COMMIT="a8b25eff3eea742b949012e512de7c69886e7794"
readonly TENSORFLOW_COMMIT="f5302ed4fa99b7ec697e578057a1f61445a442fe"
readonly TFLM_ESP_KERNELS_COMMIT="e06bd902394dfd7c21f14377623c157700431e43"
