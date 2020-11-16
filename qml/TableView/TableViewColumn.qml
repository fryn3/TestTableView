import QtQuick 2.12
import QtQuick.Controls 1.3

TableViewColumn {
    id: column

    property int minimumSize: 50
    property int maximumSize: 9999

    readonly property bool isRestoreWidth: tableName && tableName.length > 0
    property string tableName: '' // Using for restore width on each table view
    property string __restoreKey: tableName + role
    property var savedWidth: null
    property real originalWidth: width
    property bool sortable: true

    function getData(rowIndex) {
        var listdata = __view.__listView.children[0],
            item = listdata.children[rowIndex + 1] ? listdata.children[rowIndex + 1].rowItem : undefined

        if (item) {
            return item.itemModelData
        }

        return undefined;
    }

    horizontalAlignment: Text.AlignHCenter
}
