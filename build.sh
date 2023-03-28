#!/bin/bash

# Build script for write-xl. Only runs on linux. Builds android.

export BIN=`pwd`/write-xl.apk
export LITEXL_REPOS="file://`pwd`:main https://github.com/adamharrison/lite-xl-libgit2.git"
export LITEXL_PLUGINS="write-xl"
cp -r template lib/lite-xl-android && cd lib/lite-xl-android && ./build.sh


