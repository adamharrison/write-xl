export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64

declare -a TARGETS=("armv7a-linux-androideabi" "i686-linux-android" "aarch64-linux-android" "x86_64-linux-android")
declare -a OPENSSL_TARGETS=("android-arm" "android-x86" "android-arm64" "android-x86_64")

export CWD=`pwd`
export OPENSSL=`pwd`/openssl

for TARGET_IDX in {0..3}
do

export TARGET=${TARGETS[TARGET_IDX]}
export OPENSSL_TARGET=${OPENSSL_TARGETS[TARGET_IDX]}


export API=26
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME

export DESTINATION=$CWD/builds/$API/$TARGET

rm -rf $DESTINATION
mkdir -p $DESTINATION

export PATH=$TOOLCHAIN/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
cd $OPENSSL && CFLAGS="-fPIC" ./Configure $OPENSSL_TARGET  threads no-engine no-tests no-shared --prefix=$CWD/builds/$API/$TARGET -fPIC && make clean && make distclean
cd $OPENSSL && CFLAGS="-fPIC" ./Configure $OPENSSL_TARGET  threads no-engine no-tests no-shared --prefix=$CWD/builds/$API/$TARGET -fPIC && make -j 12 && make install_sw install_ssldirs

done
