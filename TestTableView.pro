QT += quick qml

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

include(../IT_QMLRepository/IT_QMLRepository.pri)
#include(../VariantMapModel/VariantMapModel.pri)
#include(../SomeBigTableModel/SomeBigTableModel.pri)
include(../SubtableModel/SubtableModel.pri)
include(../UNP128M2/unp128m2.pri)

SOURCES += \
        appengine.cpp \
        main.cpp \
        testmodel.cpp \
        vectormodel.cpp

HEADERS += \
    appengine.h \
    testmodel.h \
    vectormodel.h



RESOURCES += qml.qrc \
    icons.qrc

DESTDIR = ../Bin

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH +=$PWD/qml

# Additional import path used to resolve QML modules just for Qt Quick Designer
#QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

