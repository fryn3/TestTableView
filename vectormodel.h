#pragma once

#include "subtablemodel.h"

class VectorModel : public SubtableModel
{
    Q_OBJECT
public:
    static const QString MODULE_NAME;   // VectorM
    static const QString ITEM_NAME;     // VectorModel
    static const bool IS_QML_REG;
    VectorModel(QString nameTester, QObject *parent = nullptr);
    virtual ~VectorModel() = default;

    enum VectorRole {
        // cell
        VectorRoleReserveData,
        // vertical header
        VectorRoleAddBreakPoint,

        VectorRoleCOUNT
    };
    Q_ENUM(VectorRole)
    static const std::array<QString, VectorRoleCOUNT> VECTOR_ROLE_STR;

public:
    QVariant data(const QModelIndex &index, int role) const override;
    int totalRowCount() const override;
    int totalColumnCount() const override;
};

