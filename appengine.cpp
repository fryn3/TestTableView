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

const std::array<uint16_t, AppEngine::DevTypeCOUNT> AppEngine::DEV_CODE { 0x0020, 0x0021 };

static QHash<uint16_t, AppEngine::DevType> creatHash() {
    QHash<uint16_t, AppEngine::DevType> r;
    for (uint i = 0; i < AppEngine::DEV_CODE.size(); ++i) {
        r[AppEngine::DEV_CODE[i]] = AppEngine::DevType(i);
    }
    return r;
}

const QHash<uint16_t, AppEngine::DevType> AppEngine::CODE_DEV = creatHash();

AppEngine::AppEngine(QObject *parent) : QObject(parent) {
// unp128m2_tp_vector_get
    ViStatus  status;
    ViSession viRM;

    do {
        status = viOpenDefaultRM( &viRM );
        if (status < VI_SUCCESS) break;

        //будем искать все устройства Informtest
        //
        ViFindList viList;
        ViUInt32   devCnt = 0;
        ViChar     devDscr[255];
        ViChar     devTempl[128] = "PXI?*INSTR{VI_ATTR_MANF_ID == 0x1E1B}";
        ViUInt32   slot, model = 0;
        status = viFindRsrc( viRM, devTempl, &viList, &devCnt, devDscr );
        while (VI_SUCCESS == status)
        {
            // пытаемся подключиться чтобы определить слот и тип устройства
            //
            ViSession viDev;
            status = viOpen( viRM, devDscr, VI_EXCLUSIVE_LOCK, 0, &viDev );
            if (status == VI_SUCCESS) {
                status = viIn32(viDev, VI_PXI_BAR0_SPACE, 0x0, &slot);
                if (status == VI_SUCCESS) {
                    slot = (slot >> 8) & 0x0f;
                    viGetAttribute(viDev,VI_ATTR_MODEL_CODE,&model);
                    // При неизвестных устройствах, записывать код DevTypeCOUNT
                    _dev.push_back(Device(devDscr,
                                    CODE_DEV.value(model, DevTypeCOUNT),
                                    int(slot)));
                }
            }
            viClose(viDev);
            status = viFindNext( viList, devDscr );
        }
        viClose( viList );
        viClose( viRM );
    } while(0);
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
