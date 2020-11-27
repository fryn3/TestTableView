import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property alias model: table.model
    property alias tableItem: table
    property int splitOrientation: Qt.Vertical

    property int _tableCount: model.subtableCount

    property int cacheBuffer: 50

    property QtObject selection: QtObject {
        property int startRow: -1
        property int startColumn: -1
        property int endRow: -1
        property int endColumn: -1
        property int activeRow: -1
        property int activeColumn: -1

        property bool mouseSelection: false
        property point _startPos
        property int hoverRow: -1
        property int hoverColumn: -1

        property point _refPoint: Qt.point(0,0)
        property point _refCell: Qt.point(-1, -1)

        function _normalizeBounds() {
            if (startRow > endRow)
                startRow = endRow + (endRow = startRow, 0);
            if (startColumn > endColumn)
                startColumn = endColumn + (endColumn = startColumn, 0);
            startColumn = Math.max(0, startColumn);
            startRow = Math.max(0, startRow);
            endColumn = Math.min(endColumn, table._totalColumnCount() - 1);
            endRow = Math.min(endRow, table._totalRowCount() - 1);
            activeRow = Math.min(Math.max(0, activeRow), table._totalRowCount() - 1);
            activeColumn = Math.min(Math.max(0, activeColumn), table._totalColumnCount() - 1);
        }

        function _collapseToActive() {
            startRow = endRow = activeRow;
            startColumn = endColumn = activeColumn;
        }
    }

    property Component headerDelegate: Rectangle {
        color: view ? view.model.subtableHeaderData(view.subModelIndex, modelData.index,
                                                 root.splitOrientation, view.model.getStrRole("background"))
                    : "#535353"

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

            text: view ? root.model.subtableHeaderData(view.subModelIndex, modelData.index,
                                             root.splitOrientation, view.model.getStrRole("display"))
                       : ""

            elide: Text.ElideRight
            color: "#ffffff"
            renderType: Text.NativeRendering
        }
    }

    property Component cellDeleagate: Rectangle {
        id: cellDelegate

        property bool isEditMode: false

        implicitWidth: table.model.headerData(column, Qt.Horizontal, table.model.getStrRole("width")) || 100
        implicitHeight: table.model.headerData(row, Qt.Vertical, table.model.getStrRole("height")) || 50

        border.color: "#2E2D2D"
        color: view ? view.model.subtableData(view.subModelIndex,
                                                modelData.row, modelData.column,
                                                view.model.getStrRole("background"))
                    : "#414141"
        clip: true

        TextEdit {
            id: textView

            anchors.fill: parent
            visible: isEditMode
            textFormat: TextEdit.AutoText
            cursorVisible: !readOnly && activeFocus
            readOnly: !view || view.model.subtableData(view.subModelIndex,
                                                  modelData.row, modelData.column,
                                                  view.model.getStrRole("readOnly"))
            text: view ? view.model.subtableData(view.subModelIndex,
                                       modelData.row, modelData.column,
                                       view.model.getStrRole("display"))
                       : ""
            wrapMode: Text.Wrap
            selectByMouse: true
            color: "#ffffff"
            horizontalAlignment:view ? view.model.subtableData(view.subModelIndex,
                                                            modelData.row, modelData.column,
                                                            view.model.getStrRole("alignment")) & 0x0F
                                            : TextEdit.AlignHCenter
            verticalAlignment: view ? view.model.subtableData(view.subModelIndex,
                                                           modelData.row, modelData.column,
                                                           view.model.getStrRole("alignment")) & 0xE0
                                           : TextEdit.AlignVCenter

            onActiveFocusChanged: if (!activeFocus) isEditMode = false;

            Keys.onEscapePressed: {
                isEditMode = false;
                text = view ? view.model.subtableData(view.subModelIndex,
                                                      modelData.row, modelData.column,
                                                      view.model.getStrRole("display"))
                                      : "";
            }
            Keys.onPressed: {
                if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                    table.model.subtableSetData(table.subModelIndex, row, column, textView.text, table.model.getStrRole("display"))
                    isEditMode = false;
                    event.accepted = true;
                }
            }
        }

        Text {
            anchors.fill: parent
            textFormat: TextEdit.RichText
            text: textView.text
            visible: !isEditMode
            wrapMode: Text.Wrap
            color: "#ffffff"
            horizontalAlignment: textView.horizontalAlignment
            verticalAlignment: textView.verticalAlignment
        }

        MouseArea {
            anchors.fill: parent
            enabled: !view || view.model.subtableData(view.subModelIndex,
                                                      modelData.row, modelData.column,
                                                      view.model.getStrRole("enabled"))

            onDoubleClicked: {
                if (!modelData.readOnly) {
                    isEditMode = true;
                    textView.forceActiveFocus();
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

    function positionViewAtCell(row, column, alignment) {
        row = Math.min(Math.max(row, 0), model.totalRowCount() - 1);
        column = Math.min(Math.max(column, 0), model.totalColumnCount() - 1);
        let  subTableIndex = splitOrientation === Qt.Vertical
             ? Math.floor(row / model.subtableSizeMax) : Math.floor(column / model.subtableSizeMax)
        if (subTableIndex === 0) {
            table.positionViewAtCell(row, column, alignment);
        } else {
            let tableLoader = d.subtables[subTableIndex];
            if (tableLoader.status === Loader.Ready) {
                tableLoader.item.positionViewAtCell(row, column, alignment);
            } else {
                tableLoader.statusChanged.connect(function fun() {
                                                      if (tableLoader.status === Loader.Ready) {
                                                          tableLoader.item.positionViewAtCell(row, column, alignment);
                                                          tableLoader.statusChanged.disconnect(fun);
                                                      }
                                                  });
                if (!tableLoader.active) {
                    if (splitOrientation === Qt.Vertical)
                        table.contentY = tableLoader.topMargin
                    else
                        table.contentX = tableLoader.leftMargin
                }
            }
        }
    }

    function selectCell(row, column) {
        let  subTableIndex = splitOrientation === Qt.Vertical
             ? Math.floor(row / model.subtableSizeMax) : Math.floor(column / model.subtableSizeMax)
        if (subTableIndex === 0) {
            table.selectCell(row, column);
        } else {
            let tableLoader = d.subtables[subTableIndex];
            if (tableLoader.status === Loader.Ready) {
                tableLoader.item.selectCell(row, column);
            } else {
                tableLoader.statusChanged.connect(function fun() {
                                                      if (tableLoader.status === Loader.Ready) {
                                                          tableLoader.item.selectCell(row, column);
                                                          tableLoader.statusChanged.disconnect(fun);
                                                      }
                                                  });
                if (!tableLoader.active) {
                    if (splitOrientation === Qt.Vertical)
                        table.contentY = tableLoader.topMargin
                    else
                        table.contentX = tableLoader.leftMargin
                }
            }
        }
    }

    clip: true

    QtObject {
        id: d

        function initSubTables (count) {
            let loaded = 0;
            subtables[0] = table;
            for (let i = 0; i < count; ++i) {
                let subTableObj = subTableComponent.createObject(root, {subModelIndex: i+1});
                if (subTableObj == null) {
                    console.warn("Error creating subtable");
                    continue;
                }
                subtables[i+1] = subTableObj;
                loaded++;
            }
            tableToLoadCount = loaded;
            console.log("Total %1 subtables created".arg(loaded));
        }

        function updateLayout() {
            forceLayout();
            if (root.splitOrientation === Qt.Vertical)
                contentTablesVChanged();
            if (root.splitOrientation === Qt.Horizontal)
                contentTablesHChanged();
        }

        function calcSubtablesSize(subTable) {
            let startIndex = 0, endIndex = root._tableCount;
            if (subTable !== undefined) {
                startIndex = subTable;
                endIndex = subTable +1
            }

            for (let tableIndex = startIndex; tableIndex < endIndex; tableIndex++) {
                let totalSize = 0
                for (let i = 0; i < root.model.subtableSizeMax; i++) {
                    if (root.splitOrientation === Qt.Vertical) {
                        totalSize += table.model.subtableHeaderData(tableIndex, i, Qt.Vertical,
                                                                    root.model.getStrRole("height"));
                    } else {
                        totalSize += table.model.subtableHeaderData(tableIndex, i, Qt.Horizontal,
                                                                    root.model.getStrRole("width"));
                    }
                }
                subtablesSize[tableIndex] = totalSize;
            }
            calcComplete = true;
            subtablesSizeChanged();
        }

        function tablesSizeSum(from, to) {
            if (!calcComplete)
                return 0;
            var sum = 0;
            for (let i = from; i < to; i++) {
                sum += subtablesSize[i];
            }
            return sum;
        }

        property int completeTableCounter: 0
        property int tableToLoadCount: -1
        property var contentTablesH: []
        property var contentTablesV: []

        property var subtables: ({})
        property var subtablesSize: ({})
        property bool calcComplete: false

        signal forceLayout()

        onCompleteTableCounterChanged: if (completeTableCounter === tableToLoadCount) updateLayout()
        onTableToLoadCountChanged: if (completeTableCounter === tableToLoadCount) updateLayout()

        Component.onCompleted: {
            calcSubtablesSize()
        }
    }

    Keys.onPressed: {
        if (table.selection.startColumn < 0 || table.selection.startRow < 0)
            return;

        if (event.key == Qt.Key_Right) {
            if (event.modifiers & Qt.ShiftModifier) {
                if (table.selection.activeColumn === table.selection.endColumn ) {
                    table.selection.startColumn++;
                    positionViewAtCell(table.selection.activeRow, table.selection.startColumn);
                } else {
                    table.selection.endColumn++;
                    positionViewAtCell(table.selection.activeRow, table.selection.endColumn);
                }
            } else {
                table.selection.activeColumn++;
                table.selection._collapseToActive();
                positionViewAtCell(table.selection.activeRow, table.selection.endColumn);
            }
        }
        if (event.key == Qt.Key_Left) {
            if (event.modifiers & Qt.ShiftModifier) {
                if (table.selection.activeColumn === table.selection.startColumn) {
                    table.selection.endColumn--;
                    positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
                } else {
                    table.selection.startColumn--;
                    positionViewAtCell(table.selection.activeRow, table.selection.startColumn);
                }
            } else {
                table.selection.activeColumn--;
                table.selection._collapseToActive();
                positionViewAtCell(table.selection.activeRow, table.selection.startColumn);
            }
        }
        if (event.key == Qt.Key_Down) {
             if (event.modifiers & Qt.ShiftModifier) {
                 if (table.selection.activeRow === table.selection.endRow) {
                     table.selection.startRow++;
                     positionViewAtCell(table.selection.startRow, table.selection.activeColumn);
                 } else {
                     table.selection.endRow++;
                     positionViewAtCell(table.selection.endRow, table.selection.activeColumn);
                 }
             } else {
                 table.selection.activeRow++;
                 table.selection._collapseToActive();
                 positionViewAtCell(table.selection.endRow, table.selection.activeColumn);
             }
        }
        if (event.key == Qt.Key_Up) {
            if (event.modifiers & Qt.ShiftModifier) {
                if (table.selection.activeRow === table.selection.startRow) {
                    table.selection.endRow--;
                    positionViewAtCell(table.selection.endRow, table.selection.activeColumn);
                } else {
                    table.selection.startRow--;
                    positionViewAtCell(table.selection.startRow, table.selection.activeColumn);
                }
            } else {
                table.selection.activeRow--;
                table.selection._collapseToActive();
                positionViewAtCell(table.selection.startRow, table.selection.activeColumn);
            }
        }

        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {

            if (event.modifiers & Qt.ShiftModifier) {
                table.selection.activeRow--;
                if (table.selection.startColumn !== table.selection.endColumn ||
                        table.selection.startRow !== table.selection.endRow ) {
                    if (table.selection.activeRow < Math.min(table.selection.startRow , table.selection.endRow)) {
                        table.selection.activeRow = Math.max(table.selection.startRow, table.selection.endRow);
                        table.selection.activeColumn--;
                        if (table.selection.activeColumn < Math.min(table.selection.startColumn, table.selection.endColumn))
                            table.selection.activeColumn = Math.max(table.selection.startColumn, table.selection.endColumn);
                    }
                } else {
                    if (table.selection.activeRow < 0) {
                        table.selection.activeRow = table._totalRowCount() - 1;
                        table.selection.activeColumn--;
                        if (table.selection.activeColumn < 0)
                            table.selection.activeColumn = table._totalColumnCount() - 1;
                    }
                    table.selection._collapseToActive();
                }
            } else {
                table.selection.activeRow++;
                if (table.selection.startColumn !== table.selection.endColumn ||
                        table.selection.startRow !== table.selection.endRow ) {
                    if (table.selection.activeRow > Math.max(table.selection.startRow , table.selection.endRow)) {
                        table.selection.activeRow = Math.min(table.selection.startRow, table.selection.endRow);
                        table.selection.activeColumn++;
                        if (table.selection.activeColumn > Math.max(table.selection.startColumn, table.selection.endColumn))
                            table.selection.activeColumn = Math.min(table.selection.startColumn, table.selection.endColumn);
                    }
                } else {
                    if (table.selection.activeRow >= table._totalRowCount()) {
                        table.selection.activeRow = 0;
                        table.selection.activeColumn++;
                        if (table.selection.activeColumn >= table._totalColumnCount())
                            table.selection.activeColumn = 0;
                    }
                    table.selection._collapseToActive();
                }
            }
            positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
        }
        if (event.key == Qt.Key_Tab) {
            table.selection.activeColumn++;
            if (table.selection.startColumn !== table.selection.endColumn ||
                    table.selection.startRow !== table.selection.endRow ) {
                if (table.selection.activeColumn > Math.max(table.selection.startColumn, table.selection.endColumn)) {
                    table.selection.activeColumn = Math.min(table.selection.startColumn, table.selection.endColumn);
                    table.selection.activeRow++;
                    if (table.selection.activeRow > Math.max(table.selection.startRow, table.selection.endRow))
                        table.selection.activeRow = Math.min(table.selection.startRow, table.selection.endRow);
                }
            } else {
                if (table.selection.activeColumn >= table._totalColumnCount()) {
                    table.selection.activeColumn = 0;
                    table.selection.activeRow++;
                    if (table.selection.activeRow >= table._totalRowCount())
                        table.selection.activeRow = 0;
                }
                table.selection._collapseToActive();
            }
            positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
        }
        if (event.key == Qt.Key_Backtab) {
            table.selection.activeColumn--;
            if (table.selection.startColumn !== table.selection.endColumn ||
                    table.selection.startRow !== table.selection.endRow ) {
                if (table.selection.activeColumn < Math.min(table.selection.startColumn, table.selection.endColumn)) {
                    table.selection.activeColumn = Math.max(table.selection.startColumn, table.selection.endColumn);
                    table.selection.activeRow--;
                    if (table.selection.activeRow < Math.min(table.selection.startRow, table.selection.endRow))
                        table.selection.activeRow = Math.max(table.selection.startRow, table.selection.endRow);
                }
            } else {
                if (table.selection.activeColumn < 0) {
                    table.selection.activeColumn = table._totalColumnCount() - 1;
                    table.selection.activeRow--;
                    if (table.selection.activeRow < 0)
                        table.selection.activeRow = table._totalRowCount() - 1;
                }
                table.selection._collapseToActive();
            }
            positionViewAtCell(table.selection.activeRow, table.selection.activeColumn);
        }
       table.selection._normalizeBounds();
       event.accepted = true;
    }

    Component.onCompleted: {
        d.initSubTables(root._tableCount - 1);
    }

    onWidthChanged: d.updateLayout()
    onHeightChanged: d.updateLayout()

    CustomTableView {
        id: table

        property int subModelIndex: 0
        property int splitOrientation: root.splitOrientation

        anchors.fill: parent
        headerDelegate: root.headerDelegate
        scrollByWheel: false

        columnWidthProvider: (column) => {
                                 let _column = _absColumn(column)
                                 return table._savedWidth[_column]
                                 ? table._savedWidth[_column]
                                 : root.model.subtableHeaderData(subModelIndex, column, Qt.Horizontal, root.model.getStrRole("width"))
                             }
        rowHeightProvider: (row) => {
                               let _row = _absRow(row)
                               return table._savedHeight[_row]
                               ? table._savedHeight[_row]
                               : root.model.subtableHeaderData(subModelIndex, row, Qt.Vertical, root.model.getStrRole("height"))
                           }

        _absRow: (row) => root.model.absoluteRow(row, subModelIndex)
        _absColumn: (column) => root.model.absoluteColumn(column, subModelIndex)
        _totalColumnCount: () => root.model.totalColumnCount()
        _totalRowCount: () => root.model.totalRowCount()
        _roleToInt: (role) => root.model.getStrRole(role)

        bottomMargin: {
            let cHeight = (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                           ? table.ScrollBar.horizontal.height : 0);
            if (table.splitOrientation == Qt.Horizontal)
                return cHeight;

            return d.tablesSizeSum(1, root.model.subtableCount) + cHeight;
        }
        rightMargin: {
            let cWidth = (table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                          ? table.ScrollBar.vertical.width : 0);

            if (table.splitOrientation == Qt.Vertical)
                return cWidth;

            return d.tablesSizeSum(1, root.model.subtableCount)
        }

        z: 1000

        cellDeleagate: root.cellDeleagate

        onLayoutUpdated: d.updateLayout()

        Connections {
            target: d

            function onForceLayout() {
                table.forceLayout()
            }
        }
    }

    Component {
        id: subTableComponent

        Loader {
            id: loader

            property bool isVisible: {
                if (root.splitOrientation === Qt.Horizontal) {
                    let contX = table.contentX
                    return (d.tablesSizeSum(0, subModelIndex + 1) >= (contX - root.cacheBuffer)) &&
                           (d.tablesSizeSum(0, subModelIndex - 1) <= (contX + root.width - table.leftPadding + root.cacheBuffer))
                } else {
                    let contY = table.contentY
                    return ((d.tablesSizeSum(0, subModelIndex + 1)) >= (contY - root.cacheBuffer)) &&
                           ((d.tablesSizeSum(0, subModelIndex - 1)) <= (contY + root.height - table.topPadding + root.cacheBuffer))
                }
            }
            property int subModelIndex: 0
            property QtObject selection: null

            property real topMargin: {
                if (root.splitOrientation == Qt.Horizontal)
                    return 0;
                return d.tablesSizeSum(0, subModelIndex) + table.topPadding;
            }
            property real bottomMargin: {
                let cHeight = (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                               ? table.ScrollBar.horizontal.height : 0);
                if (root.splitOrientation == Qt.Horizontal)
                    return cHeight;
                return d.tablesSizeSum(subModelIndex + 1, root.model.subtableCount) - cHeight;
            }
            property real leftMargin: {
                if (root.splitOrientation == Qt.Vertical)
                    return 0;
                return d.tablesSizeSum(0, subModelIndex) + table.leftPadding;
            }
            property real rightMargin: {
                let cWidth = (table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                              ? table.ScrollBar.vertical.width : 0);

                if (root.splitOrientation  == Qt.Vertical)
                    return cWidth;
                return d.tablesSizeSum(subModelIndex + 1, root.model.subtableCount) - cWidth;
            }

            anchors {
                top: parent.top
                left: parent.left
            }
            width: root.width
            height: root.height

            active: isVisible

            sourceComponent: CustomTableView {
                id: sTable

                property int subModelIndex: loader.subModelIndex

                property int splitOrientation: root.splitOrientation

                headerDelegate: root.headerDelegate

                selection: table.selection
                cellDeleagate: root.cellDeleagate
                scrollByWheel: false

                contentX: table.contentX + (root.splitOrientation === Qt.Horizontal
                                            ? -leftMargin : 0)
                contentY: table.contentY + (root.splitOrientation === Qt.Vertical
                                             ? -topMargin : 0)

                columnWidthProvider: (column) => {
                                         let _column = _absColumn(column)
                                         return table._savedWidth[_column]
                                         ? table._savedWidth[_column]
                                         : root.model.subtableHeaderData(subModelIndex, column, Qt.Horizontal, root.model.getStrRole("width"))
                                     }
                rowHeightProvider: (row) => {
                                       let _row = _absRow(row)
                                       return table._savedHeight[_row]
                                       ? table._savedHeight[_row]
                                       : root.model.subtableHeaderData(subModelIndex, row, Qt.Vertical, root.model.getStrRole("height"))
                                   }

                _setContentX: (x) => {
                                  table.contentX = x  + (root.splitOrientation === Qt.Horizontal
                                                         ? -leftMargin : 0) ;
                                  table.returnToBounds();
                              }
                _setContentY: (y) => {
                                  table.contentY = y - (root.splitOrientation === Qt.Vertical
                                                        ? -topMargin : 0)
                                  table.returnToBounds();
                              }


                _absRow: (row) => root.model.absoluteRow(row, subModelIndex)
                _absColumn: (column) => root.model.absoluteColumn(column, subModelIndex)
                _totalColumnCount: () => root.model.totalColumnCount()
                _totalRowCount: () => root.model.totalRowCount()
                _roleToInt: (role) => root.model.getStrRole(role)
                _flick: (xVel, yVel) => table.flick(xVel, yVel)
                _cancelFlick: () => table.cancelFlick()

                onLayoutUpdated: d.updateLayout()

                topMargin: loader.topMargin
                bottomMargin: loader.bottomMargin
                leftMargin: loader.leftMargin
                rightMargin: loader.rightMargin

                model: table.model

                reuseItems: true

                interactive: false
                ScrollBar.vertical: null
                ScrollBar.horizontal: null
                frame: null

                _savedWidth: table._savedWidth
                _savedHeight: table._savedHeight

                Component.onCompleted: {
                    if (root.splitOrientation === Qt.Vertical) {
                        d.contentTablesV[subModelIndex] = contentHeight;
                        hHeaderVisible = false;
                    }
                    if (root.splitOrientation === Qt.Horizontal) {
                        d.contentTablesH[subModelIndex] = contentWidth;
                        vHeaderVisible = false;
                    }

                    d.completeTableCounter++;
                }

                Connections {
                    target: d

                    function onForceLayout() {
                        sTable.forceLayout()
                    }
                }
            }
        }
    }

    MouseArea {
        anchors {
            fill: parent
            topMargin: table.topPadding
            bottomMargin: table.bottomPadding
            leftMargin: table.leftPadding
            rightMargin: table.rightPadding
        }

        acceptedButtons: Qt.NoButton
        hoverEnabled: false
        cursorShape: table._cursorShape
        preventStealing: true
        propagateComposedEvents: true
        z: 2000
        onWheel: {
            table.cancelFlick();
            if (wheel.modifiers & Qt.ShiftModifier) {
                table.flick(wheel.angleDelta.y * 7, 0);
                return;
            }
            table.flick(0, wheel.angleDelta.y * 7);
        }
    }
}

