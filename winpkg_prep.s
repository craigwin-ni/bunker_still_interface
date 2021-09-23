
ver=`cat ./version.txt`
echo version=$ver

c:/Qt/5.15.2/msvc2019_64/bin/windeployqt --qmldir C:/Users/Craig/Dev-Qt/BSI/BunkerStillInterface C:/Users/Craig/Dev-Qt/BSI/build-BunkerStillInterface-Desktop_Qt_5_15_2_MSVC2019_64bit-Release/release/alpha.0.0

cp -r ~/AppData/Roaming/BunkerStillInterface/* ~/Dev-Qt/BSI/writable_files
