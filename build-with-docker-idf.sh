#!/bin/bash

winpty docker run -i -t -v /$(pwd):/src espressif-idf-v4.0.1 bash

