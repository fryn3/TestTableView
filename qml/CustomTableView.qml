import QtQuick 2.15
import QtQuick.Controls 2.15

TableView {
    id: table

    property Component frame: Rectangle {
        color: "#00000000"
        border.color: "#383838"
    }

    property Component corner: Rectangle {
        color: "#535353"
    }

    property Component headerDelegate: Rectangle {
        color: "#535353"

        Rectangle {
            height: orientation === Qt.Vertical ? 1 : parent.height - 6
            width: orientation === Qt.Vertical ? parent.width - 6 : 1
            x: orientation === Qt.Vertical ? 3 : 1
            y: orientation === Qt.Vertical ? 1 : 3
            color: modelData.background || "#383838"
        }

        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: orientation === Qt.Vertical ? Text.AlignRight
                                                             : Text.AlignHCenter
            anchors.leftMargin: horizontalAlignment === Text.AlignLeft ? 12 : 1
            anchors.rightMargin: horizontalAlignment === Text.AlignRight ? 8 : 1
            text: modelData.display
            elide: Text.ElideRight
            color: "#ffffff"
            renderType: Text.NativeRendering
        }
    }

    property Component cellDeleagate: Rectangle {
        implicitWidth: table.model.headerData(column, Qt.Horizontal, table.model.getStrRole("width")) || 100
        implicitHeight: table.model.headerData(row, Qt.Vertical, table.model.getStrRole("height")) || 50

        border.color: "#2E2D2D"
        color: selection.highlight ? "#3A3A3A" : modelData.background
        clip: true
        enabled: false//modelData.enabled

//        TextEdit {
//            id: textView
//            anchors.fill: parent

//            readOnly: modelData.readOnly
//            cursorVisible: !readOnly && activeFocus
//            textFormat: TextEdit.AutoText
//            text: modelData.display
//            color: "#ffffff"
//            wrapMode: Text.Wrap
//            selectByMouse: true
//            horizontalAlignment: modelData.alignment & 0x0F || TextEdit.AlignHCenter
//            verticalAlignment: modelData.alignment & 0xE0 || TextEdit.AlignVCenter
//        }
        Text{
            id: textView
            anchors.fill: parent

//            readOnly: modelData.readOnly
//            cursorVisible: !readOnly && activeFocus
            textFormat: TextEdit.AutoText
            text: modelData.display
            color: "#ffffff"
            wrapMode: Text.Wrap
//            selectByMouse: true
            horizontalAlignment: modelData.alignment & 0x0F || TextEdit.AlignHCenter
            verticalAlignment: modelData.alignment & 0xE0 || TextEdit.AlignVCenter
        }
        Rectangle {
            anchors {
                fill: parent
                topMargin: selection.top ? 1 : -1
                bottomMargin: selection.bottom ? 1 : -1
                leftMargin: selection.left ? 1 : -1
                rightMargin: selection.right ? 1 : -1
            }

            visible: selection.highlight
            color: "#00000000"
            border.color: "#7284FF"
        }
    }

    property real minCellWidth: 10
    property real minCellHeight: 10

    property real handleOversize: 5

    property bool fixedRowHeight: false
    property bool fixedColumnWidth: false

    property bool vHeaderVisible: true
    property bool hHeaderVisible: true

    property real leftPadding: vHeaderVisible ? vHeaderView.width : 0
    property real topPadding: hHeaderVisible ? hHeaderView.height : 0

    signal layoutUpdated()

    property var _savedWidth: ({})
    property var _savedHeight: ({})

    property int _subModelIndex: 0
    property int _splitOrientation: Qt.Vertical

    property real _contentHeight: contentHeight
    property real _contentWidth: contentWidth

    property QtObject selectionObj: QtObject {
        property int startRow: -1
        property int startColumn: -1
        property int rowsCount: 0
        property int columnsCount: 0

        property bool mouseSelection: false
        property point _startPos
        property int hoverRow: -1
        property int hoverColumn: -1
    }

    property QtObject hHeaderView: HorizontalHeaderView {
        id: horizontalHeader

        property int _editWidthIndex: -1
        property int _hoverIndex: -1

        anchors {
            left: parent.left
            leftMargin: vHeaderVisible ? vHeaderView.width : 0
        }
        parent: table.parent
        syncView: table
        interactive: false
        visible: hHeaderVisible
        z:1000

        delegate: MouseArea {
            id: hDelegate

            property int _index: table.model.absoluteColumn(model.index, table._subModelIndex)

            implicitWidth: table.columnWidthProvider(hDelegate._index)
            implicitHeight: 22
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor

            onContainsMouseChanged: {
                if (containsMouse)
                    horizontalHeader._hoverIndex = hDelegate._index;
                else
                    horizontalHeader._hoverIndex = -1;
            }

            Loader {
                readonly property int orientation: Qt.Horizontal
                readonly property int index: hDelegate._index
                readonly property bool hovered: mouseAreaH.containsMouse
                readonly property bool pressed: mouseAreaH.pressed
                readonly property var modelData: model
                readonly property CustomTableView view: table

                anchors.fill: parent
                sourceComponent: table.headerDelegate
            }

            MouseArea {
                id: mouseAreaH

                anchors {
                    leftMargin: -width / 2
                    left: parent.left
                }
                height: parent.height
                width: table.handleOversize * 2
                cursorShape: Qt.SizeHorCursor
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                visible: !table.fixedColumnWidth && hDelegate._index > 0

                onContainsMouseChanged: {
                    if (containsMouse && horizontalHeader._editWidthIndex > -1 && horizontalHeader._editWidthIndex !== hDelegate._index-1)
                        return;
                    if (containsMouse)
                        horizontalHeader._editWidthIndex = hDelegate._index-1;
                    else
                        horizontalHeader._editWidthIndex = -1;
                }
            }
        }

        MouseArea {
            property point pressPoint: Qt.point(-1,-1)
            property real currentWidth: -1
            property int _index: horizontalHeader._editWidthIndex

            anchors.fill: parent
            hoverEnabled: true

            cursorShape: _index >=0 && pressed ? Qt.SizeHorCursor : Qt.PointingHandCursor

            onPressed: {
                if (_index > -1) {
                    pressPoint = Qt.point(mouseX, mouseY);
                    currentWidth = table._savedWidth[_index] || 150;
                } else {
                    selectionObj.startRow = 0;
                    selectionObj.startColumn = horizontalHeader._hoverIndex;
                    selectionObj.rowsCount = table.model.totalRowCount();
                    selectionObj.columnsCount = 1;
                }
            }

            onPositionChanged: {
                currentWidth = table._savedWidth[_index] = Math.max(table.minCellWidth,
                                                                 currentWidth + (mouse.x - pressPoint.x))
                pressPoint = Qt.point(mouse.x,mouse.y);

                table.forceLayout()
                table.layoutUpdated();
            }

            onReleased: {
                currentWidth = table._savedWidth[_index] = Math.max(minCellWidth, currentWidth + (mouse.x - pressPoint.x))
                table.forceLayout()
                table.layoutUpdated();
                pressPoint = Qt.point(-1,-1);
            }
        }
    }

    property QtObject vHeaderView: VerticalHeaderView {
        id: verticalHeader

        property int _editHeightIndex: -1
        property int _hoverIndex: -1

        parent: table.parent
        anchors {
            top: parent.top
            topMargin: hHeaderVisible ? hHeaderView.height : 0
        }
        syncView: table
        interactive: false
        z:1000
        visible: vHeaderVisible

        delegate: MouseArea {
            id: vDelegate

            property int _index: table.model.absoluteRow(model.index, table._subModelIndex)

            implicitWidth: 100
            implicitHeight: table.rowHeightProvider(vDelegate._index)
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor

            onContainsMouseChanged: {
                if (containsMouse)
                    verticalHeader._hoverIndex = vDelegate._index;
                else
                    verticalHeader._hoverIndex = -1;
            }

            Loader {
                readonly property int orientation: Qt.Vertical
                readonly property int index: vDelegate._index
                readonly property bool hovered: mouseAreaV.containsMouse
                readonly property bool pressed: mouseAreaV.pressed
                readonly property var modelData: model
                readonly property CustomTableView view: table

                anchors.fill: parent
                sourceComponent: table.headerDelegate
            }

            MouseArea {
                id: mouseAreaV

                anchors {
                    topMargin: -height / 2
                    top: parent.top
                }
                width: parent.width
                height: table.handleOversize * 2
                cursorShape: Qt.SizeVerCursor
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                visible: !table.fixedRowHeight && vDelegate._index > 0

                onContainsMouseChanged: {
                    if (containsMouse && verticalHeader._editHeightIndex > -1
                            && verticalHeader._editHeightIndex !== vDelegate._index - 1)
                        return;
                    if (containsMouse)
                        verticalHeader._editHeightIndex = vDelegate._index-1;
                    else
                        verticalHeader._editHeightIndex = -1;
                }
            }
        }

        MouseArea {
            property point pressPoint: Qt.point(-1,-1)
            property real currentHeight: -1
            property int _index: verticalHeader._editHeightIndex

            anchors.fill: parent
            hoverEnabled: true

            cursorShape: _index >=0 && pressed ? Qt.SizeVerCursor : Qt.PointingHandCursor

            onPressed: {
                if (_index > -1) {
                    pressPoint = Qt.point(mouseX, mouseY);
                    currentHeight = table._savedHeight[_index] || 51;
                } else {
                    selectionObj.startRow = verticalHeader._hoverIndex;
                    selectionObj.startColumn = 0;
                    selectionObj.rowsCount = 1;
                    selectionObj.columnsCount = table.model.totalColumnCount();
                }
            }

            onPositionChanged: {
                currentHeight = table._savedHeight[_index] = Math.max(table.minCellHeight,
                                                                 currentHeight + (mouse.y - pressPoint.y))
                pressPoint = Qt.point(mouse.x,mouse.y);

                table.forceLayout();
                table.layoutUpdated();
            }

            onReleased: {
                currentHeight = table._savedHeight[_index] = Math.max(minCellHeight, currentHeight + (mouse.y - pressPoint.y))
                table.forceLayout()
                table.layoutUpdated();
                pressPoint = Qt.point(-1,-1);
            }
        }
    }

//    function cellAtDeltaPos(row, column, x, y) {
//        console.log("### cellAtDeltaPos (row, column, x, y) ", row, column, x, y)


//        Array.prototype.forEach.call(visibleChildren[0].visibleChildren, function(child) {
//            // делаем что-нибудь с объектом child
////            console.log("      ### child", child, child.x, child.y)
//        });
//    }

    anchors.leftMargin: leftPadding
    anchors.topMargin: topPadding
    x: leftPadding
    y: topPadding
    rightMargin: table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                 ? table.ScrollBar.vertical.width : 0
    bottomMargin: table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                  ? table.ScrollBar.horizontal.height : 0

    reuseItems: true

    columnWidthProvider: (column) => {
                             let _column = column + (table._splitOrientation === Qt.Horizontal
                                                     ? table._subModelIndex * table.model.subTableSizeMax : 0)
                             return table._savedWidth[_column] ? table._savedWidth[_column]
                                                               : -1
                         }
    rowHeightProvider: (row) => {
                           let _row = row + (table._splitOrientation === Qt.Vertical
                                             ? table._subModelIndex * table.model.subTableSizeMax : 0)
                           return table._savedHeight[_row] ? table._savedHeight[_row]
                                                           : -1
                       }
    interactive: false
    boundsBehavior: Flickable.StopAtBounds

    delegate: Loader {
        id: delegateLoader

        readonly property CustomTableView view: table
        readonly property var modelData: model
        readonly property int row: table.model.absoluteRow(model.row, table._subModelIndex)
        readonly property int column: table.model.absoluteColumn(model.column, table._subModelIndex)

        property QtObject selection: QtObject {
            readonly property bool highlight: {
                let endRow = selectionObj.startRow + selectionObj.rowsCount,
                    endCol = selectionObj.startColumn + selectionObj.columnsCount;
                return row >= Math.min(selectionObj.startRow, endRow) && row <= Math.max(selectionObj.startRow, endRow) &&
                        column >= Math.min(selectionObj.startColumn, endCol) && column <= Math.max(selectionObj.startColumn, endCol);
            }
            readonly property bool top: highlight &&
                                        table.model.absoluteRow(model.row, table._subModelIndex) ===
                                        Math.min(selectionObj.startRow, selectionObj.startRow + selectionObj.rowsCount)
            readonly property bool bottom: highlight &&
                                           table.model.absoluteRow(model.row, table._subModelIndex) ===
                                           Math.max(selectionObj.startRow, selectionObj.startRow + selectionObj.rowsCount)
            readonly property bool left: highlight &&
                                         table.model.absoluteColumn(model.column,
                                                                    table._subModelIndex) ===
                                         Math.min(selectionObj.startColumn, selectionObj.startColumn + selectionObj.columnsCount)
            readonly property bool right: highlight &&
                                          table.model.absoluteColumn(model.column,
                                                                     table._subModelIndex) ===
                                          Math.max(selectionObj.startColumn, selectionObj.startColumn + selectionObj.columnsCount)
        }

        sourceComponent: table.cellDeleagate

        MouseArea {
            id: selectionMouseArea

            property point refPoint: Qt.point(0,0)
            property point refCell: Qt.point(column, row)

            anchors.fill: parent

            onContainsMouseChanged: {
                selectionObj.hoverRow = row;
                selectionObj.hoverColumn = column;
            }

            onPositionChanged: {
                if (!pressed)
                    return;
                if (!selectionObj.mouseSelection) {
                    selectionObj.mouseSelection = true;
                }
                let dx = mouse.x - refPoint.x, dy = mouse.y - refPoint.y,
                    dRow = refCell.y, dColumn = refCell.x,
                    colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width")),
                    rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));

                if (dx >= 0) {
                    while (dx > colWidth && dColumn < table.columns - 1) {
                        dx -= colWidth;
                        dColumn++;
                        refPoint.x += colWidth;
                        colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));
                        refCell.x = dColumn;
                    }
                } else {
                    while (dx < 0 && dColumn > 0) {
                        dColumn--;
                        colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));
                        dx += colWidth;
                        refPoint.x -= colWidth;
                        refCell.x = dColumn;
                    }
                }

                if (dy >= 0) {
                    while (dy > rowHeight && dRow < table.columns - 1) {
                        dy -= rowHeight;
                        dRow++;
                        refPoint.y += rowHeight;
                        rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));
                        refCell.y = dRow;
                    }
                } else {
                    while (dy < 0 && dRow > 0) {
                        dRow--;
                        rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));
                        dy += rowHeight;
                        refPoint.y -= rowHeight;
                        refCell.y = dRow;
                    }
                }

                selectionObj.rowsCount = dRow - selectionObj.startRow
                selectionObj.columnsCount = dColumn - selectionObj.startColumn
            }

            onReleased: {
                if (selectionObj.mouseSelection)
                    selectionObj.mouseSelection = false
                refPoint = Qt.point(0, 0);
                refCell = Qt.point(column, row);
            }

            onPressed: {
                if (mouse.modifiers & Qt.ShiftModifier &&
                        selectionObj.startRow >= 0 && selectionObj.startColumn >= 0) {

                    selectionObj.rowsCount = Math.abs(row - selectionObj.startRow);
                    selectionObj.columnsCount = Math.abs(column - selectionObj.startColumn);

                    if (selectionObj.rowsCount == 0 && selectionObj.columnsCount == 0) {
                        selectionObj.startRow = -1
                        selectionObj.startColumn = -1
                        return;
                    }

                    selectionObj.startRow = Math.min(selectionObj.startRow, row);
                    selectionObj.startColumn = Math.min(selectionObj.startColumn, column);
                    return;
                }

                refPoint = Qt.point(0, 0);
                refCell = Qt.point(column, row);

                selectionObj.startRow = row;
                selectionObj.startColumn = column;
                selectionObj.rowsCount = selectionObj.columnsCount = 0
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        bottomPadding: table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                       ? table.ScrollBar.horizontal.height : 0
        minimumSize: 0.05
        z: 1002
        background: Rectangle {
            implicitHeight: 7
            implicitWidth: 7

            color: "#535353"

            Rectangle {
                anchors {
                    fill: parent
                    topMargin: 4
                    bottomMargin: 4 + (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                                       ? table.ScrollBar.horizontal.height : 0)
                    leftMargin: 2
                    rightMargin: 3
                }
                color: "#c1c0c0"
                opacity: 0.3
            }
        }

        contentItem: Item {
            implicitWidth: 5
            implicitHeight: 100
            Rectangle {
                anchors {
                    fill: parent
                    topMargin: 2
                    bottomMargin: 4
                    rightMargin: 1
                }
                color: "#C1C0C0"
            }
        }
    }
    ScrollBar.horizontal: ScrollBar {
        rightPadding: table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                      ? table.ScrollBar.vertical.width : 0
        minimumSize: 0.05
        background: Rectangle {
            implicitHeight: 7
            implicitWidth: 7

            color: "#535353"

            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: 4
                    rightMargin: 4 + (table.ScrollBar.vertical && visible
                                      ? table.ScrollBar.vertical.width : 0)
                    margins: 2
                }
                color: "#c1c0c0"
                opacity: 0.3
            }
        }

        contentItem: Item {
            implicitWidth: 100
            implicitHeight: 5
            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: 2
                    rightMargin: 4
                    bottomMargin: 1
                }
                color: "#C1C0C0"
            }
        }
    }

    Keys.onPressed: {
        if (selectionObj.startColumn < 0 || selectionObj.startRow < 0)
            return;


        if (event.key == Qt.Key_Right) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startColumn++;
            if (selectionObj.startColumn >= table.columns)
                selectionObj.startColumn = 0;
        }
        if (event.key == Qt.Key_Left) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startColumn--;
            if (selectionObj.startColumn < 0)
                selectionObj.startColumn = table.columns - 1;
        }
        if (event.key == Qt.Key_Down) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startRow++;
            if (selectionObj.startRow >= table.rows)
                selectionObj.startRow = 0;
        }
        if (event.key == Qt.Key_Up) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startRow--;
            if (selectionObj.startRow < 0)
                selectionObj.startRow = table.rows - 1;
        }

        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startRow++;
            if (selectionObj.startRow >= table.rows) {
                selectionObj.startRow = 0;
                selectionObj.startColumn++;
                if (selectionObj.startColumn >= table.columns)
                    selectionObj.startColumn = 0;
            }
        }
        if (event.key == Qt.Key_Tab) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startColumn++;
            if (selectionObj.startColumn >= table.columns) {
                selectionObj.startColumn = 0;
                selectionObj.startRow++;
                if (selectionObj.startRow >= table.rows)
                    selectionObj.startRow = 0;
            }
        }
        if (event.key == Qt.Key_Backtab) {
            selectionObj.rowsCount = selectionObj.columnsCount = 0;
            selectionObj.startColumn--;
            if (selectionObj.startColumn < 0) {
                selectionObj.startColumn = table.columns - 1;
                selectionObj.startRow--;
                if (selectionObj.startRow < 0)
                    selectionObj.startRow = table.rows - 1;
            }
        }
        event.accepted = true;
    }

    Loader {
        id: cornerLoader

        z: 1001
        parent: table.parent
        anchors {
            top: parent.top
            left: parent.left
        }
        active: hHeaderVisible && vHeaderVisible
        visible: active
        width: vHeaderVisible ? vHeaderView.width : 0
        height: hHeaderVisible ? hHeaderView.height : 0

        sourceComponent: table.corner
    }

    Loader {
        id: frameLoader

        z: 1001
        parent: table.parent
        anchors {
            fill: parent
            leftMargin: vHeaderVisible ? vHeaderView.width : 0
            topMargin: hHeaderVisible ? hHeaderView.height : 0
        }

        sourceComponent: table.frame
    }
}
