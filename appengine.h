#pragma once

#include <QObject>
#include <QAbstractItemModel>

#include "vectormodel.h"

class AppEngine : public QObject
{
    Q_OBJECT
public:
    static const QString MODULE_NAME;   // AppEngine
    static const QString ITEM_NAME;     // App
    static const bool IS_QML_REG;

    AppEngine(QObject* parent = nullptr);
    virtual ~AppEngine() = default;

    Q_INVOKABLE bool getConfigPins(QString fileName);
    Q_INVOKABLE bool openVectors(QString fileName);
    Q_INVOKABLE bool saveVectors(QString fileName);
    Q_INVOKABLE bool selectDevice(QString nameDevice);
    Q_INVOKABLE bool downloadResults();
    Q_INVOKABLE bool tactView(bool isTact);
    Q_INVOKABLE bool errInScan(bool inScan);
    Q_INVOKABLE bool prevError();
    Q_INVOKABLE bool nextError();
    Q_INVOKABLE bool prevFind(QString data, bool inBus);
    Q_INVOKABLE bool nextFind(QString data, bool inBus);
    Q_INVOKABLE bool prevScan();
    Q_INVOKABLE bool nextScan();
    Q_INVOKABLE VectorModel* vectorsModel();
    Q_INVOKABLE QAbstractItemModel* scanModel();

};

