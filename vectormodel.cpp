#include "vectormodel.h"

VectorModel::VectorModel(QString nameTester, QObject *parent) : SubtableModel(parent)
{
    /*
     * Устанавливает связь с тестером, может читает статус тестера и тд
    */
    Q_UNUSED(nameTester);
}

QVariant VectorModel::data(const QModelIndex &index, int role) const
{
    return QVariant();
}

int VectorModel::totalRowCount() const
{
    return 0;
}

int VectorModel::totalColumnCount() const
{
    return 0;
}
