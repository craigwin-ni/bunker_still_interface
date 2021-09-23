
ver=`cat version.txt`
echo VERSION=$ver
cp -f ./build-BSI-Android_Qt_5_15_2_Clang_Multi_Abi-Release/android-build/build/outputs/apk/debug/android-build-debug.apk ./BunkerStillInterface_${ver}_android.apk
