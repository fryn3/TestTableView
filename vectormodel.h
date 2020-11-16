#pragma once

#include "subtablemodel.h"

#include <QTimer>

class VectorModel : public SubtableModel
{
    Q_OBJECT

public:
    static const QString MODULE_NAME;   // VectorM
    static const QString ITEM_NAME;     // VectorModel
    static const bool IS_QML_REG;
    VectorModel(int rows = 5, int columns = 5, QObject *parent = nullptr);
    virtual ~VectorModel() = default;

    enum VectorRole {
        // cell
        VectorRoleSecondValue,
        // vertical header
        VectorRoleAddBreakPoint,

        VectorRoleCOUNT
    };
    Q_ENUM(VectorRole)
    static const std::array<QString, VectorRoleCOUNT> VECTOR_ROLE_STR;

    Q_INVOKABLE bool setColumnCount(int count);
    Q_INVOKABLE void setRowCount(int count);
private:

    int _columnCount, _rowCount;
    QMap<int, QMap<int, QHash<int, QVariant>>> _data;
    std::array<QMap<int, QHash<int, QVariant>>, 2> _headData;
public:
    Q_INVOKABLE int totalRowCount() const override;
    Q_INVOKABLE int totalColumnCount() const override;
    Q_INVOKABLE QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const override;
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    Q_INVOKABLE QVariant headerData(int section, Qt::Orientation orientation, int role) const override;
    Q_INVOKABLE bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role) override;
    Q_INVOKABLE bool insertRows(int row, int count, const QModelIndex &parent) override;
    Q_INVOKABLE bool insertColumns(int column, int count, const QModelIndex &parent) override;
    Q_INVOKABLE bool removeRows(int row, int count, const QModelIndex &parent) override;
    Q_INVOKABLE bool removeColumns(int column, int count, const QModelIndex &parent) override;

};

