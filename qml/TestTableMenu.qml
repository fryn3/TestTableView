import QtQuick 2.15
import QtQuick.Controls 2.15

import Controls 12.34
import Theme 12.34


MenuBar {
    id: _menu
    height: ThemeSizes.menu
    background: Rectangle {
        color: ThemeColors.bar_bg
    }
    delegate: MenuBarItem {
        height: _menu.height
        contentItem: Label {
            color: ThemeColors.text_header
            text: parent.text
        }
        background: Rectangle {
            color: parent.hovered || parent.highlighted
                   ? ThemeColors.header_bg : "transparent"
        }

    }
    CustomMenu {
        title: qsTr("Файл")
        CustomMenuItem {
            text: qsTr("Новый файл")
            shortkey: "Ctrl+N"
            onTriggered:  {
                funcNewFile()
            }
        }
        CustomMenuItem {
            text: qsTr("Открыть файл")
            shortkey: "Ctrl+O"
            onTriggered: {
                funcOpenFile()
            }
        }
        CustomMenu {
            id: _recentFiles
            title: qsTr("Ранее открытые:")
            Repeater {
                model: 5
                delegate: CustomMenuItem {
                    text: modelData
                    onTriggered: console.log("open:", modelData)
                }
            }
        }
        CustomMenuItem {
            text: qsTr("Сохранить")
            shortkey: "Ctrl+S"
            onTriggered: {
                funcSaveFile()
            }
        }

        MenuSeparator {
            contentItem: Rectangle {
                implicitWidth: ThemeSizes.menuWidth
                implicitHeight: 1
                color: ThemeColors.bar_border
            }
        }
        CustomMenuItem {
            text: qsTr("Выход");
            shortkey: "Ctrl+Q"
            onTriggered: _window.close()
        }
    }
    CustomMenu {
        title: qsTr("Компиляция")
        CustomMenuItem {
            text: qsTr("Выполнить")
            shortkey: "Ctrl+R"
        }
    }
    CustomMenu {
        title: qsTr("Сведения")
        CustomMenuItem { text: qsTr("Описание работы с утилитой") }
        CustomMenuItem { text: qsTr("О программе") }
    }
}
