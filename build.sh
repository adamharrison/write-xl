#!/bin/bash

# Build script for write-xl. Only runs on linux. Builds android. 

export LITEXL_REPOS=file://`pwd`:master
export LITEXL_PLUGINS="write-xl"
cd lib/lite-xl-android && ./build.sh

