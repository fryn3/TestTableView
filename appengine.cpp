#include "appengine.h"

#include <QQmlEngine>
#include <QStringListModel>

static bool registerMe() {
    qmlRegisterType<AppEngine>(AppEngine::MODULE_NAME.toUtf8(), 12, 34, AppEngine::ITEM_NAME.toUtf8());
    return true;
}

const QString AppEngine::MODULE_NAME = "AppEngine";
const QString AppEngine::ITEM_NAME = "App";
const bool AppEngine::IS_QML_REG = registerMe();

AppEngine::AppEngine(QObject *parent) : QObject(parent) {

}

bool AppEngine::getConfigPins(QString fileName) {
    Q_UNUSED(fileName)
    return false;
}

bool AppEngine::openVectors(QString fileName) {
    Q_UNUSED(fileName)
    return false;
}

bool AppEngine::saveVectors(QString fileName) {
    Q_UNUSED(fileName)
    return false;
}

bool AppEngine::selectDevice(QString nameDevice) {
    Q_UNUSED(nameDevice)
    return false;
}

bool AppEngine::downloadResults() {
    return false;
}

bool AppEngine::tactView(bool isTact) {
    Q_UNUSED(isTact)
    return false;
}

bool AppEngine::errInScan(bool inScan) {
    Q_UNUSED(inScan);
    return false;
}

bool AppEngine::prevError() {
    return false;
}

bool AppEngine::nextError() {
    return false;
}

bool AppEngine::prevFind(QString data, bool inBus) {
    Q_UNUSED(data);
    Q_UNUSED(inBus);
    return false;
}

bool AppEngine::nextFind(QString data, bool inBus) {
    Q_UNUSED(data);
    Q_UNUSED(inBus);
    return false;
}

bool AppEngine::prevScan() {
    return false;
}

bool AppEngine::nextScan() {
    return false;
}

VectorModel *AppEngine::vectorsModel() {
    return new VectorModel(this);
}

QAbstractItemModel *AppEngine::scanModel() {
    return new VectorModel(this);
}
