import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property alias model: table.model
    property alias tableItem: table
    property int splitOrientation: Qt.Vertical

    property int _tableCount: model.subTableCount

    property int cacheBuffer: 50

    property Component headerDelegate: Rectangle {
        color: view ? view.model.subtableHeaderData(view._subModelIndex, modelData.index,
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

            text: view ? root.model.subtableHeaderData(view._subModelIndex, modelData.index,
                                             root.splitOrientation, view.model.getStrRole("display"))
                       : ""

            elide: Text.ElideRight
            color: "#ffffff"
            renderType: Text.NativeRendering
        }
    }

    property Component cellDeleagate: Rectangle {
        implicitWidth: 100
        implicitHeight: 50
        border.color: "#2E2D2D"
        color: selection.highlight ? "#3A3A3A"
                                   : view ? view.model.subtableData(view._subModelIndex,
                                                                            modelData.row, modelData.column,
                                                                            view.model.getStrRole("background"))
                                          : "#414141"
        clip: true
        enabled: !view || view.model.subtableData(view._subModelIndex,
                                                modelData.row, modelData.column,
                                                view.model.getStrRole("enabled"))
        opacity: enabled ? 1.0 : 0.5

        TextEdit {
            id: textView
            anchors.fill: parent
            textFormat: TextEdit.AutoText
            cursorVisible: !readOnly && activeFocus
            readOnly: !view || view.model.subtableData(view._subModelIndex,
                                                  modelData.row, modelData.column,
                                                  view.model.getStrRole("readOnly"))
            text: view ? view.model.subtableData(view._subModelIndex,
                                       modelData.row, modelData.column,
                                       view.model.getStrRole("display"))
                       : ""
            wrapMode: Text.Wrap
            selectByMouse: true
            color: "#ffffff"
            horizontalAlignment:view ? view.model.subtableData(view._subModelIndex,
                                                            modelData.row, modelData.column,
                                                            view.model.getStrRole("alignment")) & 0x0F
                                            : TextEdit.AlignHCenter
            verticalAlignment: view ? view.model.subtableData(view._subModelIndex,
                                                           modelData.row, modelData.column,
                                                           view.model.getStrRole("alignment")) & 0xE0
                                           : TextEdit.AlignVCenter
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

    clip: true

    QtObject {
        id: d

        function initSubTables (count) {
            let loaded = 0;
            for (let i = 0; i < count; ++i) {
                let subTableObj = subTableComponent.createObject(root, {_subModelIndex: i+1});
                if (subTableObj == null) {
                    console.warn("Error creating subtable");
                    continue;
                }
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

        property int completeTableCounter: 0
        property int tableToLoadCount: -1
        property var contentTablesH: []
        property var contentTablesV: []

        property real implicitItemWidth: 100
        property real implicitItemHeight: 50

        property real implicitTableHeight: splitOrientation == Qt.Vertical
                                           ? model.subTableSizeMax * (implicitItemHeight + table.rowSpacing) - table.rowSpacing
                                           : table.contentHeight
        property real implicitTableWidth: splitOrientation == Qt.Horizontal
                                          ? model.subTableSizeMax * (implicitItemWidth + table.columnSpacing) - table.columnSpacing
                                          : table.contentWidth

        signal forceLayout()

        onCompleteTableCounterChanged: if (completeTableCounter === tableToLoadCount) updateLayout()
        onTableToLoadCountChanged: if (completeTableCounter === tableToLoadCount) updateLayout()
    }

    Keys.onPressed: {
        if (table.selectionObj.startColumn < 0 || table.selectionObj.startRow < 0)
            return;

        table.selectionObj.rowsCount = table.selectionObj.columnsCount = 1;

        if (event.key == Qt.Key_Right) {
            table.selectionObj.startColumn++;
            if (table.selectionObj.startColumn >= table.model.totalColumnCount())
                table.selectionObj.startColumn = 0;
        }
        if (event.key == Qt.Key_Left) {
            table.selectionObj.startColumn--;
            if (table.selectionObj.startColumn < 0)
                table.selectionObj.startColumn = table.model.totalColumnCount() - 1;
        }
        if (event.key == Qt.Key_Down) {
            table.selectionObj.startRow++;
            if (table.selectionObj.startRow >= table.model.totalRowCount())
                table.selectionObj.startRow = 0;
        }
        if (event.key == Qt.Key_Up) {
            table.selectionObj.startRow--;
            if (table.selectionObj.startRow < 0)
                table.selectionObj.startRow = table.model.totalRowCount() - 1;
        }

        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
            table.selectionObj.startRow++;
            if (table.selectionObj.startRow >= table.model.totalRowCount()) {
                table.selectionObj.startRow = 0;
                table.selectionObj.startColumn++;
                if (table.selectionObj.startColumn >= table.model.totalColumnCount())
                    table.selectionObj.startColumn = 0;
            }
        }
        if (event.key == Qt.Key_Tab) {
            table.selectionObj.startColumn++;
            if (table.selectionObj.startColumn >= table.model.totalColumnCount()) {
                table.selectionObj.startColumn = 0;
                table.selectionObj.startRow++;
                if (table.selectionObj.startRow >= table.model.totalRowCount())
                    table.selectionObj.startRow = 0;
            }
        }
        if (event.key == Qt.Key_Backtab) {
            table.selectionObj.startColumn--;
            if (table.selectionObj.startColumn < 0) {
                table.selectionObj.startColumn = table.model.totalColumnCount() - 1;
                table.selectionObj.startRow--;
                if (table.selectionObj.startRow < 0)
                    table.selectionObj.startRow = table.model.totalRowCount() - 1;
            }
        }
        event.accepted = true;
    }

    Component.onCompleted: {
        d.initSubTables(root._tableCount - 1);
    }

    CustomTableView {
        id: table

        _subModelIndex: 0
        _splitOrientation: root.splitOrientation

        anchors.fill: parent
        headerDelegate: root.headerDelegate
//        interactive: false

        bottomMargin: {
            let cHeight = (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                           ? table.ScrollBar.horizontal.height : 0);
            if (table._splitOrientation == Qt.Horizontal)
                return cHeight;

            return d.implicitTableHeight * root.model.subTableCount + cHeight - contentHeight
        }
        rightMargin: {
            let cWidth = (table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                          ? table.ScrollBar.vertical.width : 0);

            if (table._splitOrientation == Qt.Vertical)
                return cWidth;

            return d.implicitTableWidth * root.model.subTableCount - contentWidth
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
                    let contX = table.contentX,
                        contW = d.implicitTableWidth
                    return ((contW * (_subModelIndex + 1)) >= (contX - root.cacheBuffer)) &&
                           ((contW * (_subModelIndex)) <= (contX + root.width - table.leftPadding + root.cacheBuffer))
                } else {
                    let contY = table.contentY,
                        contH = d.implicitTableHeight
                    return ((contH * (_subModelIndex + 1)) >= (contY - root.cacheBuffer)) &&
                           ((contH * (_subModelIndex - 1)) <= (contY + root.height - table.topPadding + root.cacheBuffer))
                }
            }
            property int _subModelIndex: 0
            property QtObject selectionObj: null

            anchors {
                top: parent.top
                left: parent.left
            }
            width: root.width
            height: root.height

            active: isVisible

            sourceComponent: CustomTableView {
                id: sTable

                _subModelIndex: loader._subModelIndex
                _splitOrientation: root.splitOrientation

                headerDelegate: root.headerDelegate

                selectionObj: table.selectionObj
                cellDeleagate: root.cellDeleagate

                contentX: table.contentX + (root.splitOrientation === Qt.Horizontal
                                            ? -leftMargin : 0)
                contentY: table.contentY + (root.splitOrientation === Qt.Vertical
                                             ? -topMargin : 0)

                onLayoutUpdated: d.updateLayout()

                topMargin: {
                    if (root.splitOrientation == Qt.Horizontal)
                        return 0;
                    return d.implicitTableHeight * (_subModelIndex+1) - contentHeight + table.topPadding;
                }
                bottomMargin: {
                    let cHeight = (table.ScrollBar.horizontal && table.ScrollBar.horizontal.visible
                                   ? table.ScrollBar.horizontal.height : 0);
                    if (root.splitOrientation == Qt.Horizontal)
                        return cHeight;
                    return d.implicitTableHeight * (root.model.subTableCount - _subModelIndex) - cHeight + contentHeight;
                }
                leftMargin: {
                    if (root.splitOrientation == Qt.Vertical)
                        return 0;
                    return d.implicitTableWidth * (_subModelIndex+1) - contentWidth + table.leftPadding;
                }
                rightMargin: {
                    let cWidth = (table.ScrollBar.vertical && table.ScrollBar.vertical.visible
                                  ? table.ScrollBar.vertical.width : 0);

                    if (root.splitOrientation  == Qt.Vertical)
                        return cWidth;
                    return d.implicitTableWidth * (root.model.subTableCount - _subModelIndex) - cWidth + contentWidth;
                }

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
                        d.contentTablesV[_subModelIndex] = contentHeight;
                        hHeaderVisible = false;
                    }
                    if (root.splitOrientation === Qt.Horizontal) {
                        d.contentTablesH[_subModelIndex] = contentWidth;
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
}
