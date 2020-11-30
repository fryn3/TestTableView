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
        color: view && modelData ? view.model.subtableHeaderData(view.subModelIndex, modelData.index,
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

            text: view && modelData ? root.model.subtableHeaderData(view.subModelIndex, modelData.index,
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

//        TextEdit {
//            id: textView

//            anchors.fill: parent
//            visible: isEditMode
//            textFormat: TextEdit.AutoText
//            cursorVisible: !readOnly && activeFocus
//            readOnly: !view || view.model.subtableData(view.subModelIndex,
//                                                  modelData.row, modelData.column,
//                                                  view.model.getStrRole("readOnly"))
//            text: view ? view.model.subtableData(view.subModelIndex,
//                                       modelData.row, modelData.column,
//                                       view.model.getStrRole("display"))
//                       : ""
//            wrapMode: Text.Wrap
//            selectByMouse: true
//            color: "#ffffff"
//            horizontalAlignment:view ? view.model.subtableData(view.subModelIndex,
//                                                            modelData.row, modelData.column,
//                                                            view.model.getStrRole("alignment")) & 0x0F
//                                            : TextEdit.AlignHCenter
//            verticalAlignment: view ? view.model.subtableData(view.subModelIndex,
//                                                           modelData.row, modelData.column,
//                                                           view.model.getStrRole("alignment")) & 0xE0
//                                           : TextEdit.AlignVCenter

//            onActiveFocusChanged: if (!activeFocus) isEditMode = false;

//            Keys.onEscapePressed: {
//                isEditMode = false;
//                text = view ? view.model.subtableData(view.subModelIndex,
//                                                      modelData.row, modelData.column,
//                                                      view.model.getStrRole("display"))
//                                      : "";
//            }
//            Keys.onPressed: {
//                if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
//                    table.model.subtableSetData(table.subModelIndex, row, column, textView.text, table.model.getStrRole("display"))
//                    isEditMode = false;
//                    event.accepted = true;
//                }
//            }
//        }

        Text {
            anchors.fill: parent
            textFormat: TextEdit.RichText
            text: view ? view.model.subtableData(view.subModelIndex,
                                       modelData.row, modelData.column,
                                       view.model.getStrRole("display"))
                       : ""
            visible: !isEditMode
            wrapMode: Text.Wrap
            color: "#ffffff"
            horizontalAlignment:view ? view.model.subtableData(view.subModelIndex,
                                                               modelData.row, modelData.column,
                                                               view.model.getStrRole("alignment")) & 0x0F
                                     : TextEdit.AlignHCenter
            verticalAlignment: view ? view.model.subtableData(view.subModelIndex,
                                                              modelData.row, modelData.column,
                                                              view.model.getStrRole("alignment")) & 0xE0
                                    : TextEdit.AlignVCenter

        }

//        MouseArea {
//            anchors.fill: parent
//            enabled: !view || view.model.subtableData(view.subModelIndex,
//                                                      modelData.row, modelData.column,
//                                                      view.model.getStrRole("enabled"))

//            onDoubleClicked: {
//                if (!modelData.readOnly) {
//                    isEditMode = true;
//                    textView.forceActiveFocus();
//                }
//            }
//        }

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
        var  subTableIndex = splitOrientation === Qt.Vertical
             ? Math.floor(row / model.subtableSizeMax) : Math.floor(column / model.subtableSizeMax)
        if (subTableIndex === 0) {
            table.positionViewAtCell(row, column, alignment);
        } else {
            let sTable = d.subtables[subTableIndex];
            if (sTable) {
                sTable.positionViewAtCell(row, column, alignment);
            } else {
                d.subtablesChanged.connect(function fun() {
                                                      if (d.subtables[subTableIndex] !== null) {
                                                          d.subtables[subTableIndex].positionViewAtCell(row, column, alignment);
                                                          d.subtablesChanged.disconnect(fun);
                                                      }
                                                  });
                if (splitOrientation === Qt.Vertical)
                    table.contentY = d.tablePosByIndex(subTableIndex)
                else
                    table.contentX = d.tablePosByIndex(subTableIndex)
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
                let sTable = d.subtables[subTableIndex];
                if (sTable) {
                    sTable.positionViewAtCell(row, column, alignment);
                } else {
                    d.subtablesChanged.connect(function fun() {
                                                          if (d.subtables[subTableIndex] !== null) {
                                                              d.subtables[subTableIndex].selectCell(row, column);
                                                              d.subtablesChanged.disconnect(fun);
                                                          }
                                                      });
                    if (splitOrientation === Qt.Vertical)
                        table.contentY = d.tablePosByIndex(subTableIndex)
                    else
                        table.contentX = d.tablePosByIndex(subTableIndex)
                }
            }
        }
    }

    clip: true

//    Timer {
//        id: loadTimer

//        interval: 30
//        repeat: false

//        onTriggered: d.loadTable(d.tablesToLoad);
//    }

    QtObject {
        id: d

        function loadTable(tablesIndexes) {
            tablesIndexes.forEach((tableIndex) => {
                if (tableIndex < 1 || tableIndex >= root._tableCount || !!subtables[tableIndex]) {
                    return;
                }
                let subTableObj = subTableComponent.createObject(root, {subModelIndex: tableIndex});
                if (subTableObj == null) {
                    console.warn("Error creating subtable %1".arg(tableIndex));
                    return;
                }
                subtables[tableIndex] = subTableObj;
            })
        }

        function initSubtablesSize() {
            for (let tableIndex = 1; tableIndex < root._tableCount; tableIndex++) {
                subtablesSize[tableIndex] = subtablesSize[0] || table.contentHeight
            }
            subtablesSizeChanged();
        }

        function tableIndexByPos(pos) {
            var sum = 0;
            for (let tableIndex = 0; tableIndex < root._tableCount; tableIndex++) {
                sum += subtablesSize[tableIndex];
                if (sum > pos)
                    return tableIndex
            }
            return 0
        }

        function tablePosByIndex(index) {
            var sum = 0;
            for (let tableIndex = 0; tableIndex < index; tableIndex++) {
                sum += subtablesSize[tableIndex];
            }
            return sum
        }

        function calcSubtablesSize(subTable) {
            console.time("calcSubtablesSize")
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
            console.timeEnd("calcSubtablesSize")
            subtablesSizeChanged();
            return true;
        }

        property int completeTableCounter: 0
        property int tableToLoadCount: -1

        property var tablesToLoad: []

        property var subtables: ({})
        property var subtablesSize: ({})

        signal forceLayout()
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

    onWidthChanged: d.forceLayout()
    onHeightChanged: d.forceLayout()

    CustomTableView {
        id: table

        property int subModelIndex: 0
        property int splitOrientation: root.splitOrientation
        property bool isCompleted: false

        function updateContentSize (orientation) {
            if (orientation === Qt.Vertical) {
                if (contentHeight != -1 &&
                        d.subtablesSize[subModelIndex] !== Math.round(height/visibleArea.heightRatio - topMargin - bottomMargin)) {
                    d.subtablesSize[subModelIndex] = Math.round(height/visibleArea.heightRatio - topMargin - bottomMargin);
//                    console.log("###updateContentSize", subModelIndex, contentHeight,  Math.round(height/visibleArea.heightRatio - topMargin - bottomMargin))
                    d.subtablesSizeChanged();
                }
            } else {
                if (contentWidth != -1 &&
                        d.subtablesSize[subModelIndex] !== Math.round(width/visibleArea.widthRatio - leftMargin - rightMargin)) {
                    d.subtablesSize[subModelIndex] =  Math.round(width/visibleArea.widthRatio - leftMargin - rightMargin);
//                    console.log("###updateContentSize", subModelIndex, contentWidth, Math.round(width/visibleArea.widthRatio - leftMargin - rightMargin))
                    d.subtablesSizeChanged();
                }
            }
        }

        function updateMargins() {
            let cHeight = (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                               ? table.ScrollBar.horizontal.height : 0);

            let cWidth = (table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                          ? table.ScrollBar.vertical.width : 0);
            var sum = 0;
            for (let i = 1; i < root._tableCount; i++) {
                sum += d.subtablesSize[i];
            }
            if (root.splitOrientation == Qt.Horizontal)
                rightMargin = sum + cWidth;
            else
                bottomMargin = sum + cHeight;
        }

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

        visibleArea.onHeightRatioChanged: if (isCompleted && root.splitOrientation === Qt.Vertical) updateContentSize(root.splitOrientation)
        visibleArea.onWidthRatioChanged: if (isCompleted && root.splitOrientation === Qt.Horizontal) updateContentSize(root.splitOrientation)

        onContentYChanged:  {
            if (root.splitOrientation === Qt.Vertical) {
                let index = d.tableIndexByPos(contentY + originY);
                let size = d.subtablesSize[index]
                index = d.tableIndexByPos(contentY + originY - size / 2);
                d.tablesToLoad = [index, index + 1];
//                loadTimer.start();
                d.loadTable(d.tablesToLoad);
            }
        }

        z: 1000

        cellDeleagate: root.cellDeleagate

        onLayoutUpdated: d.forceLayout()

        Component.onCompleted: {
            d.subtables[0] = table;
            d.initSubtablesSize()
            updateContentSize();
            console.log("Table %1 Completed:".arg(subModelIndex), topMargin , contentHeight, "(%1)".arg(d.subtablesSize[subModelIndex]) ,  bottomMargin)

            isCompleted = true;
        }

        Connections {
            target: d

            function onForceLayout() {
                table.forceLayout();
            }

            function onSubtablesSizeChanged() {
                table.updateMargins();
            }
        }
    }

    Component {
        id: subTableComponent

        CustomTableView {
            id: sTable

            property int subModelIndex: 0//loader.subModelIndex

            property int splitOrientation: root.splitOrientation

            function init() {
                hHeaderVisible = root.splitOrientation === Qt.Horizontal;
                vHeaderVisible = root.splitOrientation === Qt.Vertical;
                d.subtablesSize[subModelIndex] = contentHeight;
                contentX = Qt.binding(() => { return table.contentX + (root.splitOrientation === Qt.Horizontal
                                                              ? -leftMargin : 0)});
                contentY = Qt.binding(() => { return  table.contentY + (root.splitOrientation === Qt.Vertical
                                             ? -topMargin : 0)})

                updateMargins();
                d.subtablesSizeChanged();
                d.completeTableCounter++;
                console.log("Table %1 Completed:".arg(subModelIndex), topMargin , contentHeight, "(%1)".arg(d.subtablesSize[subModelIndex]) ,  bottomMargin)
            }

            function updateMargins() {
                let cHeight = (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                                   ? table.ScrollBar.horizontal.height : 0);

                let cWidth = (table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                              ? table.ScrollBar.vertical.width : 0);
                var sum = 0;

                if (subModelIndex === root._tableCount - 1) {
                    if (root.splitOrientation === Qt.Horizontal) {
                        leftMargin = sum + table.leftPadding;
                        rightMargin = cWidth;
                    } else {
                        topMargin = table.bottomMargin + table.topMargin + d.subtablesSize[0] - d.subtablesSize[subModelIndex];
                        bottomMargin = cHeight;
                    }
                    return;
                }

                for (let i = 0; i < root._tableCount; i++) {
                    if (i === subModelIndex) {
                        if (root.splitOrientation === Qt.Horizontal)
                            leftMargin = sum + table.leftPadding;
                        else
                            topMargin = sum + table.topPadding;
                        sum = 0;
                        continue;
                    }
                    sum += d.subtablesSize[i];
                }
                if (root.splitOrientation == Qt.Horizontal)
                    rightMargin = sum + cWidth;
                else
                    bottomMargin = sum + cHeight;
            }

            function updateContentSize (orientation) {
                if (orientation === Qt.Vertical) {
                    if (contentHeight != -1 &&
                            d.subtablesSize[subModelIndex] !== Math.round(height/visibleArea.heightRatio - topMargin - bottomMargin)) {
                        d.subtablesSize[subModelIndex] = Math.round(height/visibleArea.heightRatio - topMargin - bottomMargin);
                        d.subtablesSizeChanged();
                    }
                } else {
                    if (contentWidth != -1 &&
                            d.subtablesSize[subModelIndex] !== Math.round(width/visibleArea.widthRatio - leftMargin - rightMargin)) {
                        d.subtablesSize[subModelIndex] =  Math.round(width/visibleArea.widthRatio - leftMargin - rightMargin);
                        d.subtablesSizeChanged();
                    }
                }
            }

            width: root.width
            height: root.height
            headerDelegate: root.headerDelegate

            selection: table.selection
            cellDeleagate: root.cellDeleagate
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

            onLayoutUpdated: d.forceLayout()

            topMargin: 0
            bottomMargin:table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                         ? table.ScrollBar.horizontal.height : 0
            leftMargin: 0
            rightMargin: table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                              ? table.ScrollBar.vertical.width : 0

            model: table.model

            reuseItems: true

            interactive: false
            ScrollBar.vertical: null
            ScrollBar.horizontal: null
            frame: null

            _savedWidth: table._savedWidth
            _savedHeight: table._savedHeight

            Component.onCompleted: init()

            visibleArea.onHeightRatioChanged: if (root.splitOrientation === Qt.Vertical) updateContentSize(root.splitOrientation)
            visibleArea.onWidthRatioChanged: if (root.splitOrientation === Qt.Horizontal) updateContentSize(root.splitOrientation)

            Connections {
                target: d

                function onTablesToLoadChanged() {
                    if (!d.tablesToLoad.includes(sTable.subModelIndex)) {
                        d.subtables[sTable.subModelIndex] = null;
                        sTable.destroy();
                    }
                }

                function onForceLayout() {
                    sTable.forceLayout()
                }

                function onSubtablesSizeChanged() {
                    table.updateMargins();
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
                table.flick(wheel.angleDelta.y * 20, 0);
                return;
            }
            table.flick(0, wheel.angleDelta.y * 20);
        }
    }
}

