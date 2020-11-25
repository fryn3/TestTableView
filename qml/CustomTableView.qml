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
        id: cellDelegate

        property bool isEditMode: false

        implicitWidth: textEdit.implicitWidth
        implicitHeight: textEdit.implicitHeight

        border.color: "#2E2D2D"
        color: modelData.background
        clip: true

        TextEdit {
            id: textEdit

            anchors.fill: parent

            visible: isEditMode
            readOnly: modelData.readOnly
            cursorVisible: !readOnly && activeFocus
            textFormat: TextEdit.AutoText
            text: modelData.display
            color: "#ffffff"
            wrapMode: Text.Wrap
            selectByMouse: true
            horizontalAlignment: modelData.alignment & 0x0F || TextEdit.AlignHCenter
            verticalAlignment: modelData.alignment & 0xE0 || TextEdit.AlignVCenter
            enabled: modelData.enabled

            onActiveFocusChanged: if (!activeFocus) isEditMode = false;

            Keys.onEscapePressed: {
                isEditMode = false;
                text = modelData.display;
            }
            Keys.onPressed: {
                if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                    table.model.subtableSetData(table._subModelIndex, row, column, textEdit.text, table.model.getStrRole("display"))
                    isEditMode = false;
                    event.accepted = true;
                }
            }
        }

        Text{
            anchors.fill: parent

            visible: !isEditMode
            textFormat: TextEdit.RichText
            text: textEdit.text
            color: "#ffffff"
            wrapMode: Text.Wrap
            horizontalAlignment: modelData.alignment & 0x0F || TextEdit.AlignHCenter
            verticalAlignment: modelData.alignment & 0xE0 || TextEdit.AlignVCenter
        }

        MouseArea {
            anchors.fill: parent
            enabled: modelData.enabled

            onDoubleClicked: {
                if (!modelData.readOnly) {
                    isEditMode = true;
                    textEdit.forceActiveFocus();
                }
            }
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

        Rectangle {
            anchors {
                fill: parent
                margins: 1
            }

            visible: selection.active
            color: "#00000000"
            border.color: "#ffffff"
        }
    }

    property real minCellWidth: 10
    property real minCellHeight: 10

    property real handleOversize: 5

    property bool fixedRowHeight: false
    property bool fixedColumnWidth: false

    property bool vHeaderVisible: true
    property bool hHeaderVisible: true

    property bool scrollByWheel: true

    property real leftPadding: vHeaderVisible ? vHeaderView.width : 0
    property real topPadding: hHeaderVisible ? hHeaderView.height : 0
    property real bottomPadding: table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                                 ? table.ScrollBar.horizontal.height : 0
    property real rightPadding: table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                                ? table.ScrollBar.vertical.width : 0

    signal layoutUpdated()

    property var _savedWidth: ({})
    property var _savedHeight: ({})

    property int _subModelIndex: 0
    property int _splitOrientation: -1

    property real _contentHeight: contentHeight
    property real _contentWidth: contentWidth

    property bool _hDragActive: false
    property bool _vDragActive: false

    property var _setContentX: (x) => { contentX = x; }
    property var _setContentY: (y) => { contentY = y; }

    property int _cursorShape:  _hDragActive ? Qt.SizeHorCursor
                                             : _vDragActive ? Qt.SizeVerCursor
                                                            : Qt.ArrowCursor

    property QtObject selection: QtObject {
        property int startRow: -1
        property int startColumn: -1
        property int activeRow: -1
        property int activeColumn: -1
        property int rowsCount: 0
        property int columnsCount: 0

        property bool mouseSelection: false
        property point _startPos
        property int hoverRow: -1
        property int hoverColumn: -1

        property point _refPoint: Qt.point(0,0)
        property point _refCell: Qt.point(-1, -1)
    }

    property QtObject hHeaderView: HorizontalHeaderView {
        id: horizontalHeader

        property int _editWidthIndex: -1
        property int _hoverIndex: -1

        parent: table.parent
        anchors {
            left: parent.left
            leftMargin: vHeaderVisible ? vHeaderView.width : 0
        }
        syncView: table
        interactive: false
        z:1000
        opacity: hHeaderVisible ? 1 : 0

        delegate: Item {
            id: hDelegate

            property int _index: table.model.absoluteColumn(model.index, table._subModelIndex)

            implicitWidth: table.columnWidthProvider(_index)
            implicitHeight: 22

            MouseArea {
                id: horizontalMA

                property QtObject _realParent: null

                anchors.fill: parent

                hoverEnabled: true
                acceptedButtons: horizontalHeader._editWidthIndex > -1 ? Qt.NoButton : Qt.LeftButton
                cursorShape: table._cursorShape ||  Qt.PointingHandCursor

                onContainsMouseChanged: {
                    if (containsMouse)
                        horizontalHeader._hoverIndex = hDelegate._index;
                    else
                        horizontalHeader._hoverIndex = -1;
                }

                onPressed: {
                    if (horizontalHeader._editWidthIndex > -1)
                        return;
                    table.selection.activeRow = table.selection.startRow = 0;
                    table.selection.activeColumn = table.selection.startColumn = hDelegate._index;
                    table.selection.rowsCount = table.model.totalRowCount();
                    table.selection.columnsCount = 0;
                    table.selection._refPoint = Qt.point(0, 0);
                    table.selection._refCell = Qt.point(table.selection.startColumn, table.selection.startRow);
                }

                onPositionChanged: {
                    if (!pressed || horizontalHeader._editWidthIndex > -1)
                        return;

                    if (!table.selection.mouseSelection) {
                        table.selection.mouseSelection = true;
                        var fakeParent = fakeParentComponent.createObject(
                                    hDelegate.parent, {x: hDelegate.x, y: hDelegate.y,
                                        width: hDelegate.width, height: hDelegate.height});
                        _realParent = parent;
                        parent = fakeParent;
                    }

                    let dx = mouse.x - table.selection._refPoint.x,
                    dColumn = table.selection._refCell.x,
                    colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));

                    if (dx >= 0) {
                        while (dx > colWidth && dColumn < table.model.totalColumnCount() - 1) {
                            dx -= colWidth;
                            dColumn++;
                            table.selection._refPoint.x += colWidth;
                            colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));
                            table.selection._refCell.x = dColumn;
                        }
                    } else {
                        while (dx < 0 && dColumn > 0) {
                            dColumn--;
                            colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));
                            dx += colWidth;
                            table.selection._refPoint.x -= colWidth;
                            table.selection._refCell.x = dColumn;
                        }
                    }
                    table.selection.columnsCount = dColumn - table.selection.startColumn


                    let cursorPos = mapToItem(table, mouse.x, mouse.y, table.width, table.height);

                    if (cursorPos.x < 30) {
                        table.flick(500, 0);
                    } else if (cursorPos.x > table.width - 30) {
                        table.flick(-500, 0);
                    }
                }

                onReleased: {
                    if (table.selection.mouseSelection) {
                        table.selection.mouseSelection = false
                        let fakeParent = parent;
                        if (_realParent != null)
                            parent = _realParent;
                        else
                            destroy();
                        fakeParent.destroy();
                    }
                    table.selection._refPoint = Qt.point(0, 0);
                    table.selection._refCell = Qt.point(-1, -1);
                }
            }

            Loader {
                readonly property int orientation: Qt.Horizontal
                readonly property int index: hDelegate._index
                readonly property bool hovered: horizontalMA.containsMouse
                readonly property bool pressed: horizontalMA.pressed
                readonly property var modelData: model
                readonly property CustomTableView view: table

                anchors.fill: parent
                sourceComponent: table.headerDelegate
            }

            MouseArea {
                id: hSplitMA

                anchors {
                    leftMargin: -width / 2
                    left: parent.left
                }
                height: parent.height
                width: table.handleOversize * 2
                cursorShape:  table._cursorShape || Qt.SizeHorCursor
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                visible: !table.fixedColumnWidth && hDelegate._index > 0

                onContainsMouseChanged: {
                    if (containsMouse && horizontalHeader._editWidthIndex > -1 &&
                            horizontalHeader._editWidthIndex !== hDelegate._index-1)
                        return;
                    if (containsMouse)
                        horizontalHeader._editWidthIndex = hDelegate._index-1;
                    else
                        horizontalHeader._editWidthIndex = -1;
                }
            }
        }

        MouseArea {
            objectName: "internalMA"

            property point pressPoint: Qt.point(-1,-1)
            property real currentWidth: -1
            property int _index: horizontalHeader._editWidthIndex

            anchors.fill: parent
            hoverEnabled: true

            cursorShape: table._cursorShape || (_index >=0 && pressed
                                                ? Qt.SizeHorCursor : Qt.PointingHandCursor)

            onPressed: {
                table.cancelFlick();
                if (_index > -1) {
                    table._hDragActive = true;
                    pressPoint = Qt.point(mouseX, mouseY);
                    currentWidth = table.columnWidthProvider(_index);
                }
            }

            onPositionChanged: {
                if (_index > -1) {
                    currentWidth = table._savedWidth[_index] = Math.max(table.minCellWidth,
                                            currentWidth + (mouse.x - pressPoint.x))
                    table.model.setHeaderData(_index, Qt.Horizontal, currentWidth, table.model.getStrRole("width"));
                    pressPoint = Qt.point(mouse.x,mouse.y);
                    table.forceLayout()
                    table.layoutUpdated();
                }
            }

            onReleased: {
                table._hDragActive = false;
                currentWidth = table._savedWidth[_index]  = Math.max(table.minCellWidth,
                                                                     currentWidth + (mouse.x - pressPoint.x))
                table.model.setHeaderData(_index, Qt.Horizontal, currentWidth, table.model.getStrRole("width"));
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
        z:1001
        opacity: vHeaderVisible ? 1 : 0

        delegate: Item {
            id: vDelegate

            property int _index: table.model.absoluteRow(model.index, table._subModelIndex)

            implicitWidth: 100
            implicitHeight: table.rowHeightProvider(vDelegate._index) || 50

            MouseArea {
                id: verticalMA

                property QtObject _realParent: null

                anchors.fill: parent

                hoverEnabled: true
                acceptedButtons: verticalHeader._editHeightIndex > -1 ? Qt.NoButton : Qt.LeftButton
                cursorShape: table._cursorShape ||  Qt.PointingHandCursor

                onContainsMouseChanged: {
                    if (containsMouse)
                        verticalHeader._hoverIndex = vDelegate._index;
                    else
                        verticalHeader._hoverIndex = -1;
                }

                onPressed: {
                    if (verticalHeader._editHeightIndex > -1)
                        return;
                    table.selection.activeColumn = table.selection.startColumn = 0;
                    table.selection.activeRow = table.selection.startRow = vDelegate._index;
                    table.selection.rowsCount = 0;
                    table.selection.columnsCount = table.model.totalRowCount();
                    table.selection._refPoint = Qt.point(0, 0);
                    table.selection._refCell = Qt.point(table.selection.startColumn, table.selection.startRow);
                }

                onPositionChanged: {
                    if (!pressed || verticalHeader._editHeightIndex > -1)
                        return;

                    if (!table.selection.mouseSelection) {
                        table.selection.mouseSelection = true;
                        var fakeParent = fakeParentComponent.createObject(
                                    vDelegate.parent, {x: vDelegate.x, y: vDelegate.y,
                                        width: vDelegate.width, height: vDelegate.height});
                        _realParent = parent;
                        parent = fakeParent;
                    }

                    let dy = mouse.y - table.selection._refPoint.y,
                    dRow = table.selection._refCell.y,
                    rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));

                    if (dy >= 0) {
                        while (dy > rowHeight && dRow < table.model.totalRowCount() - 1) {
                            dy -= rowHeight;
                            dRow++;
                            table.selection._refPoint.y += rowHeight;
                            rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));
                            table.selection._refCell.y = dRow;
                        }
                    } else {
                        while (dy < 0 && dRow > 0) {
                            dRow--;
                            rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));
                            dy += rowHeight;
                            table.selection._refPoint.y -= rowHeight;
                            table.selection._refCell.y = dRow;
                        }
                    }
                    table.selection.rowsCount = dRow - table.selection.startRow


                    let cursorPos = mapToItem(table, mouse.x, mouse.y, table.width, table.height);

                    if (cursorPos.y < 30) {
                        table.flick(0, 500);
                    } else if (cursorPos.y > table.height - 30) {
                        table.flick(0, -500);
                    }
                }

                onReleased: {
                    if (table.selection.mouseSelection) {
                        table.selection.mouseSelection = false
                        let fakeParent = parent;
                        if (_realParent != null)
                            parent = _realParent;
                        else
                            destroy();
                        fakeParent.destroy();
                    }
                    table.selection._refPoint = Qt.point(0, 0);
                    table.selection._refCell = Qt.point(-1, -1);
                }
            }

            Loader {
                readonly property int orientation: Qt.Vertical
                readonly property int index: vDelegate._index
                readonly property bool hovered: verticalMA.containsMouse
                readonly property bool pressed: verticalMA.pressed
                readonly property var modelData: model
                readonly property CustomTableView view: table

                anchors.fill: parent
                sourceComponent: table.headerDelegate
            }

            MouseArea {
                id: vSplitMA

                anchors {
                    topMargin: -height / 2
                    top: parent.top
                }
                width: parent.width
                height: table.handleOversize * 2
                cursorShape:  table._cursorShape || Qt.SizeVerCursor
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
            objectName: "internalMA"

            property point pressPoint: Qt.point(-1,-1)
            property real currentHeight: -1
            property int _index: verticalHeader._editHeightIndex

            anchors.fill: parent
            hoverEnabled: true

            cursorShape: table._cursorShape || (_index >=0 && pressed
                                                ? Qt.SizeVerCursor : Qt.PointingHandCursor)

            onPressed: {
                table.cancelFlick();
                if (_index > -1) {
                    table._vDragActive = true;
                    pressPoint = Qt.point(mouseX, mouseY);
                    currentHeight = table.rowHeightProvider(_index);
                }
            }

            onPositionChanged: {
                if (_index > -1) {
                    currentHeight = table._savedHeight[_index] = Math.max(table.minCellHeight,
                                                                          currentHeight + (mouse.y - pressPoint.y))
                    table.model.setHeaderData(_index, Qt.Vertical, currentHeight, table.model.getStrRole("height"));
                    pressPoint = Qt.point(mouse.x,mouse.y);
                    table.forceLayout();
                    table.layoutUpdated();
                }
            }

            onReleased: {
                table._vDragActive = false;
                currentHeight = table._savedHeight[_index] = Math.max(table.minCellHeight,
                                                                      currentHeight + (mouse.y - pressPoint.y))
                table.model.setHeaderData(_index, Qt.Vertical, currentHeight, table.model.getStrRole("height"));
                table.forceLayout()
                table.layoutUpdated();
                pressPoint = Qt.point(-1,-1);
            }
        }
    }

    function positionViewAtCell(row, column, alignment) {
        let needHRecenter = false, needVRecenter = false;

        let hCounter = 0, vCounter = 0;
        let totalWidth = 0, totalHeight = 0;
        let nearColumn, nearRow;
        if (!alignment || alignment & (Qt.AlignCenter | Qt.AlignHCenter | Qt.AlignLeft | Qt.AlignRight)) {
            needHRecenter = true;
            Array.prototype.forEach.call(hHeaderView.visibleChildren[0].visibleChildren, function(child) {
                if (child.objectName === "internalMA")
                    return;
                if (child._index !== column) {
                    if ((nearColumn === undefined || Math.abs(column - child._index) < Math.abs(column - nearColumn))) {
                        nearColumn = child._index;
                    }
                    totalWidth += child.width;
                    hCounter++;
                    return;
                }


                let childOnViewPos = child.x - table.contentX + table.originX;
                if (!alignment) {
                    if (table.contentX > child.x)
                        table._setContentX(child.x);
                    else if ((table.contentX + table.width - rightPadding) < (child.x + child.width))
                        table._setContentX(child.x - table.width + child.width + rightPadding)
                    needHRecenter = false;
                } else if (alignment & Qt.AlignCenter || alignment & Qt.AlignHCenter) {
                    table._setContentX(table.contentX + childOnViewPos - (table.width - child.width) / 2);
                    needHRecenter = false;
                    return;
                } else if (alignment & Qt.AlignLeft) {
                    table._setContentX(child.x);
                    needHRecenter = false;
                    return;
                } else if (alignment & Qt.AlignRight) {
                    table._setContentX(child.x - table.width + child.width + rightPadding);
                    needHRecenter = false;
                    return;
                }
            });
        }

        if (!alignment || alignment & (Qt.AlignCenter | Qt.AlignVCenter | Qt.AlignTop | Qt.AlignBottom)) {
            needVRecenter = true;
            // проходим по строкам
            Array.prototype.forEach.call(vHeaderView.visibleChildren[0].visibleChildren, function(child) {
                if (child.objectName === "internalMA")
                    return;
                if (child._index !== row) {
                    if ((nearRow === undefined || Math.abs(row - child._index) < Math.abs(row - nearRow))) {
                        nearRow = child._index;
                    }
                    totalHeight += child.height;
                    vCounter++;
                    return;
                }

                let childOnViewPos = child.y - table.contentY + table.originY;
                if (!alignment) {
                    if (table.contentY > child.y)
                        table._setContentY(child.y);
                    else if ((table.contentY + table.height- bottomPadding) < (child.y + child.height))
                        table._setContentY(child.y - table.height + child.height + bottomPadding)
                    needVRecenter = false;
                } else if (alignment & Qt.AlignCenter || alignment & Qt.AlignVCenter) {
                    table._setContentY(table.contentY + childOnViewPos - (table.height - child.height) / 2);
                    needVRecenter = false;
                    return;
                } else if (alignment & Qt.AlignTop) {
                    table._setContentY(child.y);
                    needVRecenter = false;
                    return;
                } else if (alignment & Qt.AlignBottom) {
                    table._setContentY(child.y - table.height + child.height + bottomPadding);
                    needVRecenter = false;
                    return;
                }
            });
        }

        if (needHRecenter) {
            let average = totalWidth / hCounter;
            table._setContentX(table.contentX + average * (column - nearColumn));
        }
        if (needVRecenter) {
            let average = totalHeight / vCounter;
            table._setContentY(table.contentY + average * (row - nearRow));
        }
        if (needVRecenter || needHRecenter)
            setTimeout(positionViewAtCell, 50, row, column, alignment);

        table.returnToBounds();
    }

    function setTimeout(func, interval, ...params) {
        return setTimeoutComponent.createObject(table, {func, interval, params})
    }

    function selectCell(row, column) {
        selection.activeRow = selection.startRow = row;
        selection.activeColumn = selection.startColumn = column;
        selection.rowsCount = 0;
        selection.columnsCount = 0;
        table.positionViewAtCell(selection.activeRow, selection.activeColumn, Qt.AlignCenter);
    }

    anchors.leftMargin: leftPadding
    anchors.topMargin: topPadding
    x: leftPadding
    y: topPadding
    rightMargin: rightPadding
    bottomMargin: bottomPadding

    reuseItems: true
    rebound: Transition {}
    columnWidthProvider: (column) => {
        let _column = column + (table._splitOrientation === Qt.Horizontal
                               ? table._subModelIndex * table.model.subtableSizeMax : 0)
        return table._savedWidth[_column] ? table._savedWidth[_column]
                                           : table.model.headerData(_column,
                                                                 Qt.Horizontal,
                                                                 table.model.getStrRole("width"))
    }
    rowHeightProvider: (row) => {
                           let _row = row + (table._splitOrientation === Qt.Vertical
                                             ? table._subModelIndex * table.model.subtableSizeMax : 0)
                           return table._savedHeight[_row] ? table._savedHeight[_row]
                                                           : table.model.headerData(_row,
                                                                                    Qt.Vertical,
                                                                                    table.model.getStrRole("height"))
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
                let endRow = table.selection.startRow + table.selection.rowsCount,
                    endCol = table.selection.startColumn + table.selection.columnsCount;
                return row >= Math.min(table.selection.startRow, endRow) && row <= Math.max(table.selection.startRow, endRow) &&
                        column >= Math.min(table.selection.startColumn, endCol) && column <= Math.max(table.selection.startColumn, endCol);
            }
            readonly property bool active: row === table.selection.activeRow && column === table.selection.activeColumn

            readonly property bool top: highlight &&
                                        table.model.absoluteRow(model.row, table._subModelIndex) ===
                                        Math.min(table.selection.startRow, table.selection.startRow + table.selection.rowsCount)
            readonly property bool bottom: highlight &&
                                           table.model.absoluteRow(model.row, table._subModelIndex) ===
                                           Math.max(table.selection.startRow, table.selection.startRow + table.selection.rowsCount)
            readonly property bool left: highlight &&
                                         table.model.absoluteColumn(model.column,
                                                                    table._subModelIndex) ===
                                         Math.min(table.selection.startColumn, table.selection.startColumn + table.selection.columnsCount)
            readonly property bool right: highlight &&
                                          table.model.absoluteColumn(model.column,
                                                                     table._subModelIndex) ===
                                          Math.max(table.selection.startColumn, table.selection.startColumn + table.selection.columnsCount)
        }

        sourceComponent: table.cellDeleagate

        MouseArea {
            id: selectionMouseArea

            property QtObject _realParent: null

            z: 1
            preventStealing: true
            anchors.fill: parent
            cursorShape: table._cursorShape
            propagateComposedEvents: true

            onContainsMouseChanged: {
                table.selection.hoverRow = row;
                table.selection.hoverColumn = column;
            }

            onWheel: {
                if (!table.scrollByWheel)
                    return;
                table.cancelFlick();
                if (wheel.modifiers & Qt.ShiftModifier) {
                    table.flick(wheel.angleDelta.y * 20, 0);
                    return;
                }
                table.flick(0, wheel.angleDelta.y * 20);
            }

            onPositionChanged: {
                if (!pressed)
                    return;
                if (!table.selection.mouseSelection) {
                    table.selection.mouseSelection = true;

                    var fakeParent = fakeParentComponent.createObject(
                                delegateLoader.parent, {x: delegateLoader.x, y: delegateLoader.y,
                                                        width: delegateLoader.width, height: delegateLoader.height});
                    selectionMouseArea._realParent = parent;
                    selectionMouseArea.parent = fakeParent;
                }

                let dx = mouse.x - table.selection._refPoint.x, dy = mouse.y - table.selection._refPoint.y,
                    dRow = table.selection._refCell.y, dColumn = table.selection._refCell.x,
                    colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width")),
                    rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));

                if (dx >= 0) {
                    while (dx > colWidth && dColumn < table.columns - 1) {
                        dx -= colWidth;
                        dColumn++;
                        table.selection._refPoint.x += colWidth;
                        colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));
                        table.selection._refCell.x = dColumn;
                    }
                } else {
                    while (dx < 0 && dColumn > 0) {
                        dColumn--;
                        colWidth = table.model.headerData(dColumn, Qt.Horizontal, table.model.getStrRole("width"));
                        dx += colWidth;
                        table.selection._refPoint.x -= colWidth;
                        table.selection._refCell.x = dColumn;
                    }
                }

                if (dy >= 0) {
                    while (dy > rowHeight && dRow < table.model.totalRowCount() - 1) {
                        dy -= rowHeight;
                        dRow++;
                        table.selection._refPoint.y += rowHeight;
                        rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));
                        table.selection._refCell.y = dRow;
                    }
                } else {
                    while (dy < 0 && dRow > 0) {
                        dRow--;
                        rowHeight = table.model.headerData(dRow, Qt.Vertical, table.model.getStrRole("height"));
                        dy += rowHeight;
                        table.selection._refPoint.y -= rowHeight;
                        table.selection._refCell.y = dRow;
                    }
                }

                table.selection.rowsCount = dRow - table.selection.startRow
                table.selection.columnsCount = dColumn - table.selection.startColumn


                let cursorPos = mapToItem(table, mouse.x, mouse.y, table.width, table.height);
                if (cursorPos.y < 30) {
                    table.flick(0, 500);
                } else if (cursorPos.y > table.height - 30) {
                    table.flick(0, -500);
                }
                if (cursorPos.x < 30) {
                    table.flick(500, 0);
                } else if (cursorPos.x > table.width - 30) {
                    table.flick(-500, 0);
                }
            }

            onReleased: {
                if (table.selection.mouseSelection) {
                    table.selection.mouseSelection = false
                    let fakeParent = parent;
                    if (_realParent != null)
                        parent = _realParent;
                    else
                        destroy();
                    fakeParent.destroy();
                }
                table.selection._refPoint = Qt.point(0, 0);
                table.selection._refCell = Qt.point(column, row);
            }

            onPressed: {
                table.cancelFlick();
                if (mouse.modifiers & Qt.ShiftModifier &&
                        table.selection.startRow >= 0 && table.selection.startColumn >= 0) {

                    table.selection.rowsCount = Math.abs(row - table.selection.startRow);
                    table.selection.columnsCount = Math.abs(column - table.selection.startColumn);

                    if (table.selection.rowsCount == 0 && table.selection.columnsCount == 0) {
                        table.selection.activeRow = table.selection.startRow = -1
                        table.selection.activeColumn = table.selection.startColumn = -1
                        return;
                    }

                    table.selection.startRow = Math.min(table.selection.startRow, row);
                    table.selection.startColumn = Math.min(table.selection.startColumn, column);
                    return;
                }

                table.selection._refPoint = Qt.point(0, 0);
                table.selection._refCell = Qt.point(column, row);

                table.selection.activeRow = table.selection.startRow = row;
                table.selection.activeColumn = table.selection.startColumn = column;
                table.selection.rowsCount = table.selection.columnsCount = 0
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
        if (table.selection.startColumn < 0 || table.selection.startRow < 0)
            return;

        if (event.key == Qt.Key_Right) {
            if (event.modifiers & Qt.ShiftModifier) {
                table.selection.columnsCount++;
                if (table.selection.activeColumn < Math.min(table.selection.startColumn,
                                                            table.selection.startColumn + table.selection.columnsCount))
                    table.selection.activeColumn++;
                if (table.selection.startColumn >= table.model.totalColumnCount()) {
                    table.selection.activeColumn = table.selection.startColumn = table.model.totalColumnCount()-1;
                }
                if ((table.selection.startColumn + table.selection.columnsCount) >= table.model.totalColumnCount()) {
                     table.selection.columnsCount = table.model.totalColumnCount() - table.selection.startColumn - 1;
                }
            } else {
                table.selection.rowsCount = table.selection.columnsCount = 0;
                table.selection.activeColumn++;
                table.selection.startColumn = table.selection.activeColumn;
                table.selection.startRow = table.selection.activeRow;
            }

            if (table.selection.startColumn >= table.model.totalColumnCount()) {
                table.selection.activeColumn = table.selection.startColumn = table.model.totalColumnCount()-1;
            }

            positionViewAtCell(table.selection.startRow + table.selection.rowsCount,
                               table.selection.startColumn + table.selection.columnsCount)
        }
        if (event.key == Qt.Key_Left) {
            if (event.modifiers & Qt.ShiftModifier) {
                table.selection.columnsCount--;
                if (table.selection.activeColumn > Math.max(table.selection.startColumn,
                                                            table.selection.startColumn + table.selection.columnsCount))
                    table.selection.activeColumn--;
                if ((table.selection.startColumn + table.selection.columnsCount) < 0) {
                     table.selection.columnsCount = 0 - table.selection.startColumn;
                }
            } else {
                table.selection.rowsCount = table.selection.columnsCount = 0;
                table.selection.activeColumn--;
                table.selection.startColumn = table.selection.activeColumn;
                table.selection.startRow = table.selection.activeRow;
            }

            if (table.selection.startColumn < 0)
                table.selection.activeColumn = table.selection.startColumn = 0;
            positionViewAtCell(table.selection.startRow + table.selection.rowsCount,
                               table.selection.startColumn + table.selection.columnsCount)
        }
        if (event.key == Qt.Key_Down) {
            if (event.modifiers & Qt.ShiftModifier) {
                table.selection.rowsCount++;
                if (table.selection.activeRow < Math.min(table.selection.startRow,
                                                            table.selection.startRow + table.selection.rowsCount))
                    table.selection.activeRow++;
            } else {
                table.selection.rowsCount = table.selection.columnsCount = 0;
                table.selection.activeRow++;
                table.selection.startColumn = table.selection.activeColumn;
                table.selection.startRow = table.selection.activeRow;
            }

            if (table.selection.startRow >= table.model.totalRowCount())
                table.selection.activeRow = table.selection.startRow = table.model.totalRowCount() - 1;  ///TODO REPLACE

            positionViewAtCell(table.selection.startRow + table.selection.rowsCount,
                               table.selection.startColumn + table.selection.columnsCount)
        }
        if (event.key == Qt.Key_Up) {
            if (event.modifiers & Qt.ShiftModifier) {
                table.selection.rowsCount--;
                if (table.selection.activeRow > Math.max(table.selection.startRow,
                                                            table.selection.startRow + table.selection.rowsCount))
                    table.selection.activeRow--;
            } else {
                table.selection.rowsCount = table.selection.columnsCount = 0;
                table.selection.activeRow--;
                table.selection.startColumn = table.selection.activeColumn;
                table.selection.startRow = table.selection.activeRow;
            }
            if (table.selection.startRow < 0)
                table.selection.activeRow = table.selection.startRow = 0;  ///TODO REPLACE
            positionViewAtCell(table.selection.startRow + table.selection.rowsCount,
                               table.selection.startColumn + table.selection.columnsCount)
        }

        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
            table.selection.activeRow++;
            if (table.selection.rowsCount !== 0) {
                if (table.selection.activeRow >
                        Math.max(table.selection.startRow , table.selection.startRow + table.selection.rowsCount)) {
                    table.selection.activeRow = Math.min(table.selection.startRow,
                                                         table.selection.startRow + table.selection.rowsCount);
                    table.selection.activeColumn++;
                    if (table.selection.activeColumn >
                            Math.max(table.selection.startColumn, table.selection.startColumn + table.selection.columnsCount))
                        table.selection.activeColumn = Math.min(table.selection.startColumn,
                                                                table.selection.startColumn + table.selection.columnsCount);
                }
            } else {
                table.selection.startRow++;
                if (table.selection.activeRow >= table.model.totalRowCount()) {
                    table.selection.startRow = table.selection.activeRow = 0;
                    table.selection.activeColumn++;
                    table.selection.startColumn++;
                    if (table.selection.activeColumn >= table.model.totalColumnCount())
                        table.selection.startColumn = table.selection.activeColumn = 0;
                }
            }
            positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
        }
        if (event.key == Qt.Key_Tab) {
            table.selection.activeColumn++;
            if (table.selection.columnsCount !== 0) {
                if (table.selection.activeColumn >
                        Math.max(table.selection.startColumn, table.selection.startColumn + table.selection.columnsCount)) {
                    table.selection.activeColumn = Math.min(table.selection.startColumn,
                                                            table.selection.startColumn + table.selection.columnsCount);
                    table.selection.activeRow++;
                    if (table.selection.activeRow >
                            Math.max(table.selection.startRow, table.selection.startRow + table.selection.rowsCount))
                        table.selection.activeRow = Math.min(table.selection.startRow,
                                                             table.selection.startRow + table.selection.rowsCount);
                }
            } else {
                table.selection.startColumn++;
                if (table.selection.activeColumn >= table.model.totalColumnCount()) {
                    table.selection.activeColumn = table.selection.startColumn = 0;
                    table.selection.startRow++;
                    table.selection.activeRow++;
                    if (table.selection.activeRow >= table.model.totalRowCount())
                        table.selection.activeRow = table.selection.startRow = 0;
                }
            }
            positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
        }
        if (event.key == Qt.Key_Backtab) {
            table.selection.activeColumn--;

            if (table.selection.columnsCount !== 0) {
                if (table.selection.activeColumn < Math.min(table.selection.startColumn,
                                                            table.selection.startColumn + table.selection.columnsCount)) {
                    table.selection.activeColumn = Math.max(table.selection.startColumn,
                                                            table.selection.startColumn + table.selection.columnsCount);
                    table.selection.activeRow--;
                    if (table.selection.activeRow < Math.min(table.selection.startRow,
                                                             table.selection.startRow + table.selection.rowsCount))
                        table.selection.activeRow = Math.max(table.selection.startRow,
                                                             table.selection.startRow + table.selection.rowsCount);
                }
            } else {
                table.selection.startColumn--;
                if (table.selection.activeColumn < 0) {
                    table.selection.activeColumn = table.selection.startColumn = table.model.totalColumnCount() - 1;
                    table.selection.startRow--;
                    table.selection.activeRow--;
                    if (table.selection.activeRow < 0)
                        table.selection.activeRow = table.selection.startRow = table.model.totalRowCount() - 1;
                }
            }
            positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
        }
        event.accepted = true;
    }

    Component {
        id: setTimeoutComponent

        Timer {
            id: delayTimer

            property var func
            property var params

            running: true
            repeat: false
            onTriggered: {
                func(...params)
                destroy()
            }
        }
    }

    Component { id: fakeParentComponent; Item {} }

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
