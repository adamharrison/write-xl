#!/bin/bash

# Build script for write-xl. Only runs on linux.

LPM_ARGUMENTS="$LPM_ARGUMENTS --userdir user"

[[ "$@" == "clean" ]] && rm -rf user lpm && exit -1
[[ ! -f lpm ]] && curl -L https://github.com/lite-xl/lite-xl-plugin-manager/releases/download/latest/lpm.x86_64-linux > lpm && chmod +x lpm || { echo "Can't download lpm." && exit -1; }

./lpm $LPM_ARGUMENTS add . https://github.com/adamharrison/lite-xl-libgit2 && ./lpm $LPM_ARGUMENTS install write-xl || { echo "Can't install plugins." && exit -1; }
