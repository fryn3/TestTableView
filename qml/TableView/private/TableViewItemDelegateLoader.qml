import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4


Loader {
    id: itemDelegateLoader

    width: __column ? __column.width : 0
    height: parent ? parent.height : 0
    visible: __column ? __column.visible : false

    property bool isValid: false
    sourceComponent: (__model === undefined || !isValid) ? null
                     : __column && __column.delegate ? __column.delegate : __itemDelegate

    // All these properties are internal
    property int __index: index
    property Item __rowItem: null
    property var __model: __rowItem ? __rowItem.itemModel : undefined
    property var __modelData: __rowItem ? __rowItem.itemModelData : undefined
    property TableViewColumn __column: null
    property Component __itemDelegate: null
    property var __mouseArea: null
    property var __style: null

    // These properties are exposed to the item delegate
    readonly property var model: __model
    readonly property var modelData: __modelData

    property QtObject styleData: QtObject {
        readonly property int row: __rowItem ? __rowItem.rowIndex : -1
        readonly property int column: __index
        readonly property int elideMode: __column ? __column.elideMode : Text.ElideLeft
        readonly property int textAlignment: __column ? __column.horizontalAlignment : Text.AlignLeft
        readonly property bool selected: __rowItem ? __rowItem.itemSelected : false
        readonly property bool hasActiveFocus: __rowItem ? __rowItem.activeFocus : false
        readonly property bool pressed: __mouseArea && row === __mouseArea.pressedRow && column === __mouseArea.pressedColumn
        readonly property color textColor: __rowItem ? __rowItem.itemTextColor : "black"
        readonly property string role: __column ? __column.role : ""
        readonly property var value: model && model.hasOwnProperty(role) ? model[role] // Qml ListModel and QAbstractItemModel
                                     : modelData && modelData.hasOwnProperty(role) ? modelData[role] // QObjectList / QObject
                                     : modelData != undefined ? modelData : "" // Models without role
        onRowChanged: if (row !== -1) itemDelegateLoader.isValid = true
    }
}
