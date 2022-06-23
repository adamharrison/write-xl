#!/bin/bash

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64

declare -a TARGETS=("armv7a-linux-androideabi" "i686-linux-android" "aarch64-linux-android" "x86_64-linux-android")

export CWD=`pwd`

for TARGET_IDX in {0..3}
do

export TARGET=${TARGETS[TARGET_IDX]}

export API=26
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
export LDFLAGS="-L$CWD/openssl-build/builds/$API/$TARGET/lib -L$CWD/libgit2-build/builds/$API/$TARGET/lib -lgit2 -l:libssl.a -l:libcrypto.a"
export CFLAGS="-I$CWD/openssl-build/builds/$API/$TARGET/include -I$CWD/libgit2-build/builds/$API/$TARGET/include -DLITE_XL_PLUGIN  -I../../lite-xl-simplified/resources"
export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH

export DESTINATION=$CWD/builds/$API/$TARGET

rm -rf $DESTINATION
mkdir -p $DESTINATION

echo $CFLAGS

$CC ../../../user/plugins/gitsave/native.c -Bshared $CFLAGS $LDFLAGS -fPIC -shared -o $DESTINATION/native.so

done

