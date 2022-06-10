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
export LDFLAGS="-L$CWD/libgit2 -L$CWD/openssl-build/builds/$API/$TARGET/lib"
export CFLAGS="-I$CWD/libgit2/include -I$CWD/openssl-build/builds/$API/$TARGET/include"
export LD_LIBRARY_PATH="$CWD/openssl-build/builds/$API/$TARGET/lib"
export C_INCLUDE_DIRS="$CWD/openssl-build/builds/$API/$TARGET/include"
export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH

export DESTINATION=$CWD/builds/$API/$TARGET

rm -rf $DESTINATION
mkdir -p $DESTINATION

cd $CWD/libgit2 && rm -rf build && mkdir build && cd build && cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_SYSTEM_VERSION=Android -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DBUILD_CLAR=OFF -DCMAKE_FIND_ROOT_PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot;$CWD/openssl-build/builds/$API/$TARGET" -DCMAKE_INSTALL_PREFIX=$DESTINATION .. && make clean && make -j 12 && make install

done
