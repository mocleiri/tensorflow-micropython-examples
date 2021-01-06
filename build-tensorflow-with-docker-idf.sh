#!/bin/bash

winpty docker run -i -t -v /$(pwd)/tensorflow:/tensorflow espressif/idf:v4.0.2 bash

