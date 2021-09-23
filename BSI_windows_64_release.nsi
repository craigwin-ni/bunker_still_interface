
!define APPNAME "BunkerStillInterface"
!define APPABBREV "BSI"
#!define APPVERSION "alpha.0.0"  Requires APPVERSION from command line

Name "BSI_windows_64"
OutFile "${APPNAME}_${APPVERSION}_windows64.exe"
Unicode True
InstallDir $PROGRAMFILES64\${APPNAME}

Page directory
Page instfiles

Section

SetOutPath $INSTDIR\${APPVERSION}
File /r C:\Users\Craig\Dev-Qt\BSI\build-BunkerStillInterface-Desktop_Qt_5_15_2_MSVC2019_64bit-Release\release\${APPVERSION}\*

SetOutPath $APPDATA\${APPNAME}
File /r .\writable_files\*

CreateShortcut "$DESKTOP\${APPABBREV}.lnk \
  "$INSTDIR\${APPVERSION}\${APPNAME}.exe"

SectionEnd
