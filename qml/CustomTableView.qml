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
            color: "#383838"
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
        implicitWidth: 100
        implicitHeight: 50
        border.color: "#2E2D2D"
        color: selection.highlight ? "#3A3A3A" : "#414141"
        clip: true

        Text {
            id: textView
            anchors.centerIn: parent
            text: modelData.display
            color: "#ffffff"
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

    anchors.leftMargin: verticalHeader.width
    anchors.topMargin: horizontalHeader.height
    x: verticalHeader.width
    y: horizontalHeader.height
    rightMargin: table.ScrollBar.vertical.visible ? table.ScrollBar.vertical.width : 0
    bottomMargin: table.ScrollBar.horizontal.visible ? table.ScrollBar.horizontal.height : 0

    reuseItems: true

    columnSpacing: -1
    rowSpacing: -1
    columnWidthProvider: (column) => {
                             return d.__savedWidth[column] ? d.__savedWidth[column]
                                                           : 100
                         }
    rowHeightProvider: (row) => {
                           return d.__savedHeight[row] ? d.__savedHeight[row]
                                                       : 50
                       }
    boundsBehavior: Flickable.StopAtBounds

    delegate: Loader {
        id: delegateLoader

        readonly property var modelData: model

        property QtObject selection: QtObject {
            readonly property bool highlight: {
                let endRow = selectionObj.startRow + selectionObj.rowsCount,
                endCol = selectionObj.startColumn + selectionObj.columnsCount;
                return model.row >= selectionObj.startRow && model.row < endRow &&
                        model.column >= selectionObj.startColumn && model.column < endCol;
            }
            readonly property bool top: highlight && model.row === selectionObj.startRow
            readonly property bool bottom: highlight &&
                                           model.row === selectionObj.startRow + selectionObj.rowsCount - 1
            readonly property bool left: highlight && model.column === selectionObj.startColumn
            readonly property bool right: highlight &&
                                          model.column === selectionObj.startColumn + selectionObj.columnsCount - 1
        }

        sourceComponent: table.cellDeleagate

        MouseArea {
            id: selectionMouseArea
            anchors.fill: parent

            onPressed: {
                if (mouse.modifiers & Qt.ShiftModifier &&
                        selectionObj.startRow >= 0 && selectionObj.startColumn >= 0) {

                    selectionObj.rowsCount = Math.abs(row - selectionObj.startRow) + 1;
                    selectionObj.columnsCount = Math.abs(column - selectionObj.startColumn) + 1;

                    if (selectionObj.rowsCount == 1 && selectionObj.columnsCount == 1) {
                        selectionObj.startRow = -1
                        selectionObj.startColumn = -1
                        return;
                    }

                    selectionObj.startRow = Math.min(selectionObj.startRow, row);
                    selectionObj.startColumn = Math.min(selectionObj.startColumn, column);
                    return;
                }

                selectionObj.startRow = row
                selectionObj.startColumn = column
                selectionObj.rowsCount = selectionObj.columnsCount = 1
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        bottomPadding: table.ScrollBar.horizontal.visible ? table.ScrollBar.horizontal.height : 0
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
                    bottomMargin: 4 + (table.ScrollBar.horizontal.visible ? table.ScrollBar.horizontal.height : 0)
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
        rightPadding: table.ScrollBar.vertical.visible ? table.ScrollBar.vertical.width : 0
        minimumSize: 0.05
        background: Rectangle {
            implicitHeight: 7
            implicitWidth: 7

            color: "#535353"

            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: 4
                    rightMargin: 4 + (table.ScrollBar.vertical.visible ? table.ScrollBar.vertical.width : 0)
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

    QtObject {
        id: d

        readonly property var __savedWidth: ({})
        readonly property var __savedHeight: ({})
    }

    QtObject {
        id: selectionObj

        property int startRow: -1
        property int startColumn: -1
        property int rowsCount: 0
        property int columnsCount: 0
    }

    Keys.onPressed: {
        if (selectionObj.startColumn < 0 || selectionObj.startRow < 0)
            return;

        selectionObj.rowsCount = selectionObj.columnsCount = 1;

        if (event.key == Qt.Key_Right) {
            selectionObj.startColumn++;
            if (selectionObj.startColumn >= table.columns)
                selectionObj.startColumn = 0;
        }
        if (event.key == Qt.Key_Left) {
            selectionObj.startColumn--;
            if (selectionObj.startColumn < 0)
                selectionObj.startColumn = table.columns - 1;
        }
        if (event.key == Qt.Key_Down) {
            selectionObj.startRow++;
            if (selectionObj.startRow >= table.rows)
                selectionObj.startRow = 0;
        }
        if (event.key == Qt.Key_Up) {
            selectionObj.startRow--;
            if (selectionObj.startRow < 0)
                selectionObj.startRow = table.rows - 1;
        }

        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
            selectionObj.startRow++;
            if (selectionObj.startRow >= table.rows) {
                selectionObj.startRow = 0;
                selectionObj.startColumn++;
                if (selectionObj.startColumn >= table.columns)
                    selectionObj.startColumn = 0;
            }
        }
        if (event.key == Qt.Key_Tab) {
            selectionObj.startColumn++;
            if (selectionObj.startColumn >= table.columns) {
                selectionObj.startColumn = 0;
                selectionObj.startRow++;
                if (selectionObj.startRow >= table.rows)
                    selectionObj.startRow = 0;
            }
        }
        if (event.key == Qt.Key_Backtab) {
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

    HorizontalHeaderView {
        id: horizontalHeader

        property int _editWidthIndex: -1
        property int _hoverIndex: -1

        anchors {
            left: parent.left
            leftMargin: verticalHeader.width
        }
        parent: table.parent
        syncView: table
        interactive: false
        z:1000

        delegate: MouseArea {
            implicitWidth: table.columnWidthProvider(index)
            implicitHeight: 22
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor

            onContainsMouseChanged: {
                if (containsMouse)
                    horizontalHeader._hoverIndex = index;
                else
                    horizontalHeader._hoverIndex = -1;
            }

            Timer {
                running: true
                repeat: true
                interval: 1000

                onTriggered: horizontalHeader.forceLayout()
            }

            Loader {
                readonly property int orientation: Qt.Horiontal
                readonly property bool hovered: mouseAreaH.containsMouse
                readonly property bool pressed: mouseAreaH.pressed
                readonly property var modelData: model

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
                visible: !table.fixedColumnWidth && index > 0

                onContainsMouseChanged: {
                    if (horizontalHeader._editWidthIndex > -1 && horizontalHeader._editWidthIndex !== index-1)
                        return;
                    if (containsMouse)
                        horizontalHeader._editWidthIndex = index-1;
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
                    currentWidth = d.__savedWidth[_index] || 150;
                } else {
                    selectionObj.startRow = 0;
                    selectionObj.startColumn = horizontalHeader._hoverIndex;
                    selectionObj.rowsCount = table.rows;
                    selectionObj.columnsCount = 1;
                }
            }

            onPositionChanged: {
                currentWidth = d.__savedWidth[_index] = Math.max(table.minCellWidth,
                                                                 currentWidth + (mouse.x - pressPoint.x))
                pressPoint = Qt.point(mouse.x,mouse.y);

                table.forceLayout()
            }

            onReleased: {
                currentWidth = d.__savedWidth[_index] = Math.max(minCellWidth, currentWidth + (mouse.x - pressPoint.x))
                table.forceLayout()
                pressPoint = Qt.point(-1,-1);
            }
        }
    }

    VerticalHeaderView {
        id: verticalHeader

        property int _editHeightIndex: -1
        property int _hoverIndex: -1

        parent: table.parent
        anchors {
            top: parent.top
            topMargin: horizontalHeader.height
        }
        syncView: table
        interactive: false
        z:1000

        delegate: MouseArea {
            implicitWidth: 100
            implicitHeight: table.rowHeightProvider(index)
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor

            onContainsMouseChanged: {
                if (containsMouse)
                    verticalHeader._hoverIndex = index;
                else
                    verticalHeader._hoverIndex = -1;
            }

            Loader {
                readonly property int orientation: Qt.Vertical
                readonly property bool hovered: mouseAreaV.containsMouse
                readonly property bool pressed: mouseAreaV.pressed
                readonly property var modelData: model

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
                visible: !table.fixedRowHeight && index > 0

                onContainsMouseChanged: {
                    if (containsMouse && verticalHeader._editHeightIndex > -1 && verticalHeader._editHeightIndex !== index-1)
                        return;
                    if (containsMouse)
                        verticalHeader._editHeightIndex = index-1;
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
                    currentHeight = d.__savedHeight[_index] || 51;
                } else {
                    selectionObj.startRow = verticalHeader._hoverIndex;
                    selectionObj.startColumn = 0;
                    selectionObj.rowsCount = 1;
                    selectionObj.columnsCount = table.columns;
                }
            }

            onPositionChanged: {
                currentHeight = d.__savedHeight[_index] = Math.max(table.minCellHeight,
                                                                 currentHeight + (mouse.y - pressPoint.y))
                pressPoint = Qt.point(mouse.x,mouse.y);

                table.forceLayout()
            }

            onReleased: {
                currentHeight = d.__savedHeight[_index] = Math.max(minCellHeight, currentHeight + (mouse.y - pressPoint.y))
                table.forceLayout()
                pressPoint = Qt.point(-1,-1);
            }
        }
    }

    Loader {
        id: cornerLoader

        z: 1001
        parent: table.parent
        anchors {
            top: parent.top
            left: parent.left
        }
        width: verticalHeader.width
        height: horizontalHeader.height

        sourceComponent: table.corner
    }

    Loader {
        id: frameLoader

        z: 1001
        parent: table.parent
        anchors {
            fill: parent
            leftMargin: verticalHeader.width
            topMargin: horizontalHeader.height
        }

        sourceComponent: table.frame
    }
}
