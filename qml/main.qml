import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import Qt.labs.qmlmodels 1.0
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
//import Qt.labs.platform 1.1 as labs


//import IT_QMLRepository 12.34
import Controls 12.34
import Theme 12.34
import "TableView" as Table

//import "./Controls"
//import SomeBigTableModel 1.1
//import VectorM 12.34

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Like Exel")
    color: ThemeColors.bar_bg

    TestTableMenu {
        id: _menu
    }

//    property Component rowField: RowLayout {
//        property alias prOverlay: _overlay.text
//        property alias prOpacity: _opacity.text
//        Item {
//            implicitWidth: 100
//            Text {
//                text: modelData
//            }
//        }
//        TextField {
//            id: _overlay
//        }
//        TextField {
//            id: _opacity
//        }
//    }

//    ColumnLayout {
//        Component.onCompleted: {
//            _tcb.disabledOverlay = _overlayDis.text
//            _tcb.disabledOpacity = Number(_opacityDis.text)
//            _tcb.normalOverlay = _overlayNorm.text
//            _tcb.normalOpacity = Number(_opacityNorm.text)
//            _tcb.hoverOverlay = _overlayHover.text
//            _tcb.hoverOpacity = Number(_opacityHover.text)
//            _tcb.selectedOverlay = _overlaySelect.text
//            _tcb.selectedOpacity = Number(_opacitySelect.text)
//        }

//        anchors.top: _menu.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.margins: 20
//        TestColorBar {
//            id: _tcb
//            disabledOverlay: _overlayDis.text
//            disabledOpacity: Number(_opacityDis.text)
//            normalOverlay: _overlayNorm.text
//            normalOpacity: Number(_opacityNorm.text)
//            hoverOverlay: _overlayHover.text
//            hoverOpacity: Number(_opacityHover.text)
//            selectedOverlay: _overlaySelect.text
//            selectedOpacity: Number(_opacitySelect.text)
//        }

//        RowLayout {
//            property alias prOverlay: _overlayDis.text
//            property alias prOpacity: _opacityDis.text
//            Item {
//                implicitWidth: 100
//                Text {
//                    text: modelData
//                }
//            }
//            TextField {
//                id: _overlayDis
//            }
//            TextField {
//                id: _opacityDis
//            }
//        }
//        RowLayout {
//            property alias prOverlay: _overlayNorm.text
//            property alias prOpacity: _opacityNorm.text
//            Item {
//                implicitWidth: 100
//                Text {
//                    text: modelData
//                }
//            }
//            TextField {
//                id: _overlayNorm
//            }
//            TextField {
//                id: _opacityNorm
//            }
//        }
//        RowLayout {
//            property alias prOverlay: _overlayHover.text
//            property alias prOpacity: _opacityHover.text
//            Item {
//                implicitWidth: 100
//                Text {
//                    text: modelData
//                }
//            }
//            TextField {
//                id: _overlayHover
//            }
//            TextField {
//                id: _opacityHover
//            }
//        }
//        RowLayout {
//            property alias prOverlay: _overlaySelect.text
//            property alias prOpacity: _opacitySelect.text
//            Item {
//                implicitWidth: 100
//                Text {
//                    text: modelData
//                }
//            }
//            TextField {
//                id: _overlaySelect
//            }
//            TextField {
//                id: _opacitySelect
//            }
//        }

//        Repeater {
//            id: _rep
//            model: ["disabled", "normal", "hover", "selected"]
//            delegate: rowField
//            Component.onCompleted: {
//                var keys = Object.keys(_rep)
//                for (var i = 0; i < keys.length; ++i) {
//                    console.log(keys[i] + ' : ' + _rep[keys[i]])
//                }
//                console.log("hahaaa")
//                var rep0 = _rep.itemAt(0)
//                keys = Object.keys(rep0)
//                for (var i = 0; i < keys.length; ++i) {
//                    var k = keys[i]
//                    console.log(k + ' : ' + rep0[k])
//                }

//                console.log("haha")
//                _tcb.disabledOverlay = _rep.itemAt(0).prOverlay
//                _tcb.disabledOpacity = Number(_rep.itemAt(0).prOpacity)
//                _tcb.normalOverlay = _rep.itemAt(1).prOverlay
//                _tcb.normalOpacity = Number(_rep.itemAt(1).prOpacity)
//                _tcb.hoverOverlay = _rep.itemAt(2).prOverlay
//                _tcb.hoverOpacity = Number(_rep.itemAt(2).prOpacity)
//                _tcb.selectedOverlay = _rep.itemAt(3).prOverlay
//                _tcb.selectedOpacity = Number(_rep.itemAt(3).prOpacity)

//            }
//        }

//        TextField {
//            id: _fieldOverlay
//            implicitWidth: 80
//            text: "00000000"
//        }
//        TextField {
//            id: _fieldOpacity
//            implicitWidth: 80
//            text: "100"
//        }
//        Repeater {
//            model: 4
//            delegate: TestColorBar {}
//        }
//    }
//    Repeater {
//        anchors.top: _menu.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.margins: 20
//        model: 4
//        delegate: TestColorBar {}

//    }

//    ListView {
//        anchors.top: _menu.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.margins: 20
//        contentWidth: 400
//        flickableDirection: Flickable.AutoFlickDirection
//        model: 4
//        spacing: 10
//        delegate: TestColorBar {}
//    }

//    ColumnLayout {
//        anchors.top: _menu.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.margins: 20
//        TestColorBar {}
//        TestColorBar {}
//        TestColorBar {}
//        TestColorBar {}
//    }

////    Rectangle {
////        anchors.top: _menu.bottom
////        anchors.left: parent.left
////        anchors.right: parent.right
////        anchors.bottom: parent.bottom
////        color: ThemeColors.bar_bg
////    }

////    Item {
////        id: it
////        anchors.top: _menu.bottom
////        anchors.left: parent.left
////        anchors.right: parent.right
////        anchors.bottom: parent.bottom
////        clip: true
////        CustomTableView {
////            anchors.fill: parent
////            model: cppTableModel
////        }
////    }
    Item {
        id: it
        anchors.top: _menu.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        MultiTableView {

//        CustomTableView {
            id: table

            anchors.fill: parent
            focus: true
            model: cppTableModel/* {
                subTableOrientation: table.splitOrientation
                subTableSizeMax: 1024*512 // Model size: 1024*1024*128 rows and 2048 columns
            }*/
//            splitOrientation: Qt.Vertical
        }
    }
//}
}
