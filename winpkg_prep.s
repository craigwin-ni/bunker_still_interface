
VERSION=`cat ./version.txt`
EXEFILE="BunkerStillInterface.exe"
PKGSRC=C:/Users/Craig/Dev-Qt/BSI/BunkerStillInterface 
PKGPATH=C:/Users/Craig/Dev-Qt/BSI/build-BSI-Desktop_Qt_5_15_2_MSVC2019_64bit-Release/release
EXEPATH=$PKGPATH/$EXEFILE
PKGDIR=$PKGPATH/$VERSION

echo version=$VERSION
echo source=$PKGSRC
echo pkgdir=$PKGDIR
echo exe=$EXEPATH

mkdir $PKGDIR
cp $EXEPATH $PKGDIR

c:/Qt/5.15.2/msvc2019_64/bin/windeployqt --qmldir $PKGSRC $PKGDIR

# this is from older version; retained to make edited files locally available
rm -rf ~/Dev-Qt/BSI/writable_files/*
cp -r ~/AppData/Roaming/BunkerStillInterface/* ~/Dev-Qt/BSI/writable_files

