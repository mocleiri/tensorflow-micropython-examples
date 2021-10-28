#!/bin/bash

function ci_setup_microlite {
    . ./esp-idf/export.sh
    python3 -m pip install --upgrade Pillow

}