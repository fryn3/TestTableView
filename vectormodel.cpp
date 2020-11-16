#include "vectormodel.h"

#include <QColor>
#include <QQmlEngine>


static bool registerMe() {
    qmlRegisterType<VectorModel>(VectorModel::MODULE_NAME.toUtf8(), 12, 34, VectorModel::ITEM_NAME.toUtf8());
    return true;
}

const QString VectorModel::MODULE_NAME = "VectorM";
const QString VectorModel::ITEM_NAME = "VectorModel";
const bool VectorModel::IS_QML_REG = registerMe();

const std::array<QString, VectorModel::VectorRoleCOUNT> VectorModel::VECTOR_ROLE_STR {
    "secondValue",
};

VectorModel::VectorModel(int rows, int columns, QObject *parent)
    : ExcelModel(parent), _columnCount(columns), _rowCount(rows) {
    checkSubTableCountChanged();
}

bool VectorModel::setColumnCount(int count) {
    if (count < 0 || _columnCount == count) { return false; }
    if (_columnCount < count) {
        beginInsertColumns(QModelIndex(), _columnCount, count - 1);
    } else {
        beginRemoveColumns(QModelIndex(), count, _columnCount - 1);
    }
    _columnCount = count;
    endInsertColumns();
    checkSubTableCountChanged();
    return true;
}

void VectorModel::setRowCount(int count) {
    _rowCount = count;
    checkSubTableCountChanged();
}

int VectorModel::totalRowCount() const {
    return _rowCount;
}

int VectorModel::totalColumnCount() const {
    return _columnCount;
}

QHash<int, QByteArray> VectorModel::roleNames() const {
    ExcelModel::roleNames();
    const int MIN_KEY = Qt::UserRole + ExcelRoleCOUNT;
    for (int i = 0; i < VectorRoleCOUNT; ++i) {
        _rolesId.insert(MIN_KEY + i, VECTOR_ROLE_STR[i].toUtf8());
    }
    qDebug() << __PRETTY_FUNCTION__ << _rolesId;
    return _rolesId;
}

QVariant VectorModel::data(const QModelIndex &index, int role) const {
//    qDebug() << __PRETTY_FUNCTION__ << index << role;
    if (!index.isValid()
            || index.row() >= _rowCount
            || index.column() >= _columnCount) {
        return QVariant();
    }
    role = isGoodRole(role);
    if (role == -1) { return QVariant(); }
    const QString DEFAULT_VALUE
            = "<i><b>default</b> <font color=\"blue\" size=\"5\">data</font></i> <pre>[%1, %2]</pre>";

    int r = index.row();
    int c = index.column();
    // not default
    if (_data.contains(r) && _data[r].contains(c)) {
        return _data[r][c][role];
    }
    // default
    role -= Qt::UserRole;
    switch (role) {
    case ExcelRoleDisplay:
        return DEFAULT_VALUE.arg(index.row()).arg(index.column());
    case ExcelRoleAlignment:
        return (1 << (index.row() % 4)) | (0x20 << index.column() % 3);
    case ExcelRoleBackground:
        return QColor(0x80, 0, 0xFF, index.row() % 2 ? 255 : 128);
    case ExcelRoleToolTip:
        return "ExcelRoleToolTip";
    case ExcelRoleReadOnly:
        return index.column() % 2;
    case ExcelRoleEnabled:
        return bool(index.column() % 3);
    case ExcelRoleSpanH:
    case ExcelRoleSpanV:
        return index.row() == 0 && index.column() == 0 ? 2 : 1;
    case ExcelRoleValidator:
        return "[0-9a-zA-Z_]*"; // можно сделать QRegExp
    case ExcelRoleDropdown:
        return QStringList {"aaBbcc", "abc", "aAacc", "aa bb cc", "AABBCC"};
    default:
        // Обработка VectorRole.
        role -= ExcelRoleCOUNT;
        switch (role) {
        case VectorRoleSecondValue:
            return r + c / 1000.;
        default:
            qDebug() << __PRETTY_FUNCTION__ << "bad role:" << index << role;
            return QVariant();
        }
    }
}

bool VectorModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    qDebug() << __PRETTY_FUNCTION__ << index << role;
    if (!index.isValid()
            || index.row() >= _rowCount
            || index.column() >= _rowCount) {
        return false;
    }
    role = isGoodRole(role);
    if (role == -1) { return false; }
    int r = index.row();
    int c = index.column();
    _data[r][c][role] = value;
    return true;
}

QVariant VectorModel::headerData(int section, Qt::Orientation orientation, int role) const {
    switch (orientation) {
    case Qt::Horizontal:
        if (section < 0 || section >= _columnCount) { return QVariant(); }
        break;
    case Qt::Vertical:
        if (section < 0 || section >= _rowCount) { return QVariant(); }
        break;
    default:
        return QVariant();
    }
    role = isGoodRole(role);
    if (role == -1) { return QVariant(); }

    {
        int orientationIndex = orientation - Qt::Horizontal;
        if (_headData.at(orientationIndex).contains(section)) {
            return _headData[orientationIndex][section][role];
        }
    }
    role -= Qt::UserRole;
    const QString DEFAULT_H_VALUE = "Title%1";
    const QString DEFAULT_V_VALUE = "%1_%2";
    switch (orientation) {
    case Qt::Horizontal:
        switch (role) {
        case ExcelRoleDisplay:
            return DEFAULT_H_VALUE.arg(section);
        case ExcelRoleAlignment:
            return (1 << (section % 4)) | (0x20 << section % 3);
        case ExcelRoleBackground:
            return QColor(0xDA, 0x70, 0xD6, section % 2 ? 255 : 128);
        case ExcelRoleToolTip:
            return "ExcelRoleToolTip Head H";
        case ExcelRoleWidth:
            return (section % 5 + 1) * 15;
        case ExcelRoleHeight:
            return -1;
        case ExcelRoleResized:
            return section % 2;
        case ExcelRoleGroup:
            return section % 10 < 3;
        case ExcelRoleIndexInGroup:
            return section % 10 < 3 ? section % 10 : -1;
        case ExcelRoleDeploy:
            return section % 10 < 3 ? (section / 10) % 2 ? true : false : false;
        default:
            qDebug() << __PRETTY_FUNCTION__ << "bad role:" << role;
            return QVariant();
        }
    case Qt::Vertical:
        switch (role) {
        case ExcelRoleDisplay:
            return DEFAULT_V_VALUE.arg(section).arg(QChar('a' + section % 3));
        case ExcelRoleAlignment:
            return (1 << (section % 4)) | (0x20 << section % 3);
        case ExcelRoleBackground:
            return QColor(0xB8, 0x4D, 0xFF, section % 2 ? 255 : 128);
        case ExcelRoleToolTip:
            return "ExcelRoleToolTip Head V";
        case ExcelRoleWidth:
            return -1;
        case ExcelRoleHeight:
            return (section % 5 + 1) * 7;
        case ExcelRoleResized:
            return section % 2;
        case ExcelRoleGroup:
            return section % 10 < 3;
        case ExcelRoleIndexInGroup:
            return section % 10 < 3 ? section % 10 : -1;
        case ExcelRoleDeploy:
            return section % 10 < 3 ? (section / 10) % 2 ? true : false : false;
        default:
            qDebug() << __PRETTY_FUNCTION__ << "bad role:" << role;
            return QVariant();
        }
    default:
        return QVariant();
    }
}

bool VectorModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) {
    qDebug() << __PRETTY_FUNCTION__ << section << orientation << value << role;
    {
        int orientationIndex = orientation - Qt::Horizontal;
        if (_headData.at(orientationIndex).contains(section)) {
            _headData[orientationIndex][section][role] = value;
            return true;
        }
    }
    return true;
}


bool VectorModel::insertRows(int row, int count, const QModelIndex &parent) {
    if (count < 1 || row < 0 || row > totalRowCount()) {
        return false;
    }
    beginInsertRows(parent, row, row + count - 1);
    for (auto it = _data.end() - 1; it.key() >= row; --it) {
        _data[it.key() + count] = it.value();
        it = _data.erase(it);
    }
    _rowCount += count;
    endInsertRows();
    checkSubTableCountChanged();
    return true;
}

bool VectorModel::insertColumns(int column, int count, const QModelIndex &parent) {
    if (count <= 0 || column < 0 || (column + count) > totalColumnCount()) {
        return false;
    }
    beginInsertColumns(parent, column, column + count - 1);
    for (auto itR = _data.begin(); itR != _data.end(); ++itR) {
        for (auto itC = itR.value().end() - 1; itC.key() >= column; --itC) {
            itR.value()[itC.key() + count] = itC.value();
            itC = itR.value().erase(itC);
        }
    }
    _columnCount += count;
    endRemoveColumns();
    checkSubTableCountChanged();
    return true;
}

bool VectorModel::removeRows(int row, int count, const QModelIndex &parent) {
    if (count <= 0 || row < 0 || (row + count) > totalRowCount()) {
        return false;
    }
    beginRemoveRows(parent, row, row + count - 1);
    for (auto it = _data.lowerBound(row);
         it.key() < row + count;
         it = _data.erase(it));

    for (auto it = _data.lowerBound(row); it != _data.end(); it = _data.erase(it)) {
        _data[it.key() - count] = it.value();
    }
    _rowCount -= count;
    endRemoveRows();
    checkSubTableCountChanged();
    return true;
}

bool VectorModel::removeColumns(int column, int count, const QModelIndex &parent) {
    if (count <= 0 || column < 0 || (column + count) > totalColumnCount()) {
        return false;
    }
    beginRemoveColumns(parent, column, column + count + 1);

    for (auto itR = _data.begin(); itR != _data.end(); ++itR) {
        for (auto itC = itR.value().lowerBound(column);
             itC.key() < column + count;
             itC = itR.value().erase(itC));
        for (auto itC = itR.value().lowerBound(column);
             itC != itR.value().end(); itC = itR.value().erase(itC)) {
            itR.value()[itC.key() - count] = itC.value();
        }
    }
    _columnCount -= count;
    endRemoveColumns();
    checkSubTableCountChanged();
    return true;
}
