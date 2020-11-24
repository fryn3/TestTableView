#include "vectormodel.h"

#include <QQmlEngine>

static bool registerMe() {
    qmlRegisterType<VectorModel>(VectorModel::MODULE_NAME.toUtf8(), 12, 34, VectorModel::ITEM_NAME.toUtf8());
    return true;
}

const QString VectorModel::MODULE_NAME = "VectorM";
const QString VectorModel::ITEM_NAME = "VectorModel";
const bool VectorModel::IS_QML_REG = registerMe();

const std::array<QString, VectorModel::VectorRoleCOUNT> VectorModel::VECTOR_ROLE_STR {
    // cell
    "ReserveData",
    // vertical header
    "AddBreakPoint"
};

VectorModel::VectorModel(QObject *parent) : SubtableModel(parent) {
}

bool VectorModel::setConfigPin(QByteArray data) {
    Q_UNUSED(data);
    return false;
}

bool VectorModel::setVectors(QByteArray data) {
    Q_UNUSED(data);
    return false;
}

bool VectorModel::setErrorMap(QByteArray data) {
    Q_UNUSED(data);
    return false;
}

QPoint VectorModel::currentIndex() const {
    return QPoint(-1, -1);
}

bool VectorModel::setCurrentIndex(QPoint p) {
    Q_UNUSED(p);
    return false;
}

QRect VectorModel::selection() const {
    return QRect(-1, -1, 0, 0);
}

bool VectorModel::setSelection(QRect sel) {
    Q_UNUSED(sel);
    return false;
}

bool VectorModel::setSelectionAndCurrentIndex(QRect sel, QPoint p) {
    Q_UNUSED(sel);
    Q_UNUSED(p);
    return false;
}

bool VectorModel::tactView(bool isTact) {
    Q_UNUSED(isTact);
    return false;
}

bool VectorModel::prevError() {
    return false;
}

bool VectorModel::nextError() {
    return false;
}

bool VectorModel::prevFind(QString data, bool inBus) {
    Q_UNUSED(data);
    Q_UNUSED(inBus);
    return false;
}

bool VectorModel::nextFind(QString data, bool inBus) {
    Q_UNUSED(data);
    Q_UNUSED(inBus);
    return false;
}

QStringListModel* VectorModel::pins() {
    return new QStringListModel(this);
}

QVariant VectorModel::data(const QModelIndex &index, int role) const {
    Q_UNUSED(index);
    Q_UNUSED(role);
    return QVariant();
}

bool VectorModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    Q_UNUSED(index);
    Q_UNUSED(value);
    Q_UNUSED(role);
    return false;
}

int VectorModel::totalRowCount() const {
    return 0;
}

int VectorModel::totalColumnCount() const {
    return 0;
}
