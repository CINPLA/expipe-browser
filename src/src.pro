TEMPLATE = app

CONFIG += c++14

QT += qml quick widgets

SOURCES += main.cpp \
    experimentmodel.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
#include(../libs/h5cpp/library_deployment.pri)

CONFIG += conan_basic_setup
include(conanbuildinfo.pri)

LIBS += -lhdf5_serial
INCLUDEPATH += /usr/include/hdf5/serial

DISTFILES +=

HEADERS += \
    experimentmodel.h

