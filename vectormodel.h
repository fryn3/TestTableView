#pragma once

#include "subtablemodel.h"

#include <QPoint>
#include <QRect>
#include <QStringListModel>

class VectorModel : public SubtableModel
{
    Q_OBJECT
    Q_PROPERTY(QPoint currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QRect selection READ selection WRITE setSelection NOTIFY selectionChanged)
public:
    static const QString MODULE_NAME;   // VectorM
    static const QString ITEM_NAME;     // VectorModel
    static const bool IS_QML_REG;

    enum VectorRole {
        // cell
        VectorRoleReserveData,      // Для тестирования.
        // vertical header
        VectorRoleAddBreakPoint,    // Для возможности установки breakpoint.

        VectorRoleCOUNT
    };
    Q_ENUM(VectorRole)
    static const std::array<QString, VectorRoleCOUNT> VECTOR_ROLE_STR;

    VectorModel(QObject *parent = nullptr);
    virtual ~VectorModel() = default;

    /*!
     * \brief Соотвествие пинов и название столбцов
     * \param data - данные конфигурации.
     * \return true, если успешно.
     */
    bool setConfigPin(QByteArray data);

    /*!
     * \brief Получение данных векторов
     * \param data - данные векторов.
     * \return true, если успешно.
     */
    bool setVectors(QByteArray data);

    /*!
     * \brief Получает карту ошибок
     *
     * Так же получает данные результатов запуска и др.
     * \param data - данные карты ошибок
     * \return true, если успешно.
     */
    bool setErrorMap(QByteArray data);

    /*!
     * \brief Получение активной ячейки
     *
     * x - столбцы, y - строки.
     * \return активную ячейку.
     */
    QPoint currentIndex() const;

    /*!
     * \brief Установка активной ячейки
     *
     * x - столбцы, y - строки.
     * \param p - активная ячейка.
     * \return true, если успех.
     */
    bool setCurrentIndex(QPoint p);

    /*!
     * \brief Выделенная область
     *
     * x,y указывают начало выделение, а width/height на направление и
     * размер.
     * Если width == 0 или height == 0, выделена один столбец или одна строка.
     * Если width/height имеют положительное значение, направление выделение
     * вправо/вниз. Если отрицательные, то влево/вверх.
     * \return Выделенную область.
     */
    QRect selection() const;

    /*!
     * \brief Установка выделенной области
     * \param sel - область.
     * \return true, если успех.
     */
    bool setSelection(QRect sel);

    /*!
     * \brief Установка области и ячейки
     * \param sel - выделенная область.
     * \param p - активная ячейка
     * \return true, если успех.
     */
    bool setSelectionAndCurrentIndex(QRect sel, QPoint p);

    /*!
     * \brief Показывает столбец тактов
     *
     * Сортирует вектора по тактам. Активно только после получения карты
     * ошибок.
     * \param isTact - true, для показа тактов, иначе без тактов.
     * \return true, если успешно.
     */
    Q_INVOKABLE bool tactView(bool isTact);

    /*!
     * \brief Перемещает активную ячейку к предыдущей ошибке
     *
     * Работает по кругу.
     * \return false, когда нет ошибок.
     */
    Q_INVOKABLE bool prevError();

    /*!
     * \brief Перемещает активную ячейку к следующей ошибке
     *
     * Работает по кругу.
     * \return false, когда нет ошибок.
     */
    Q_INVOKABLE bool nextError();

    /*!
     * \brief Поиск в направлении начала
     *
     * Работает по кругу.
     * \param data - строка поиска.
     * \param inBus - если false, поиск по каналам. Если true, поиск по шинам.
     * \return false, когда нет результатов поиска
     */
    Q_INVOKABLE bool prevFind(QString data, bool inBus);

    /*!
     * \brief Поиск в направлении конца
     *
     * Работает по кругу.
     * \param data - строка поиска.
     * \param inBus - если false, поиск по каналам. Если true, поиск по шинам.
     * \return false, когда нет результатов поиска
     */
    Q_INVOKABLE bool nextFind(QString data, bool inBus);

    /*!
     * \brief Модель заголовков
     *
     * Будет менятся в зависимости от конфигураций пинов и при сворачивании
     * или разворачивании шин.
     * \return модель заголовков.
     */
    Q_INVOKABLE QStringListModel* pins();

signals:
    void currentIndexChanged();
    void selectionChanged();
public:
    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const override;
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    Q_INVOKABLE int totalRowCount() const override;
    Q_INVOKABLE int totalColumnCount() const override;
};

