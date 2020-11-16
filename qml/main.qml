import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import Qt.labs.qmlmodels 1.0
import QtQuick.Layouts 1.15
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

//    ToolBar {
//        id: _toolbar
//}

//    RowLayout {
//        anchors.top: _menu.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        ToolButton {
//            id: button
//            icon.source: "qrc:/icons/icons/open_file.svg"
//            icon.color: ThemeColors.transparent
//            background: Rectangle {
//                color: {
//                    if (!button.enabled) {
//                        return ThemeColors.bar_bg
//                    } else if

//                    if (button.down)
//                        return "#d6d6d6"
//                    else if ()
//                        return "#f6f6f6"
//                    else
//                        return ThemeColors.icon_btn
//                }
//            }
//        }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/save.svg"
//            icon.color: ThemeColors.transparent
//        }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/download.svg"
//            icon.color: ThemeColors.transparent
//        }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/tact_view.svg"
//            icon.color: ThemeColors.transparent
//        }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/err_back.svg"
//            icon.color: ThemeColors.transparent
//        }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/add_scan_err.svg"
//            icon.color: ThemeColors.transparent
//        }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/err_forward.svg"
//            icon.color: ThemeColors.transparent
//        }
//        ToolButton {
//            display: AbstractButton.IconOnly
//            icon.source: "qrc:/icons/icons/find.svg"
//            icon.color: ThemeColors.transparent
//        }
//        Item { Layout.fillWidth: true }
//        ToolButton {
//            icon.source: "qrc:/icons/icons/logic_analyzer.svg"
//            icon.color: ThemeColors.transparent
//        }

//        CheckBox {
//            text: "Enabled"
//            checked: true
//            Layout.alignment: Qt.AlignRight
//        }
//    }

//    Rectangle {
//        anchors.top: _menu.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.bottom: parent.bottom
//        color: ThemeColors.bar_bg
//    }

    Item {
        id: it
        anchors.top: _menu.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        CustomTableView {
            anchors.fill: parent
            model: cppTableModel
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.6600000262260437}
}
##^##*/
