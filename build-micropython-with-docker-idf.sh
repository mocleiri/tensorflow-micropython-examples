#!/bin/bash

winpty docker run -i -t -v /$(pwd)/micropython:/micropython -v /$(pwd)/src:/src espressif-idf-v4.0.1 bash

