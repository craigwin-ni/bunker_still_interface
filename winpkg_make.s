
ver=`cat version.txt`
echo $ver
C:/Program\ Files\ \(x86\)/NSIS/makensis.exe -DAPPVERSION=$ver ./BSI_windows_64_release.nsi

