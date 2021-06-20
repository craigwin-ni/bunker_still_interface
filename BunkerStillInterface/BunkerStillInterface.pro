TEMPLATE = app

QT += quick qml mqtt core gui

CONFIG += c++11

SOURCES += \
        main.cpp \
        qmlmqttclient.cpp \
        qmltextfile.cpp

HEADERS += \
        qmlmqttclient.h \
        qmltextfile.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = ./BsiDisplayObjects ./BsiProcessObjects ./BsiSystemPages

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

target.path =  c:/Users/Craig/Dev-Qt/BSI/BSI_install/
INSTALLS += target

DISTFILES +=

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    DISTFILES += \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/res/values/libs.xml
}
