import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
Item {
    implicitHeight: 50
    implicitWidth: 300
    property color disabledOverlay
    property int disabledOpacity
    property color normalOverlay
    property int normalOpacity
    property color hoverOverlay
    property int hoverOpacity
    property color selectedOverlay
    property int selectedOpacity

    RowLayout {
        anchors.fill: parent
        CheckBox {
            id: _ch
            checked: true
        }
        ColorOverlayButton {
            id: _open
            image: "qrc:/icons/icons/open_file.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _save
            image: "qrc:/icons/icons/save.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _download
            image: "qrc:/icons/icons/download.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _tactView
            image: "qrc:/icons/icons/tact_view.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _errBack
            image: "qrc:/icons/icons/err_back.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _addScanErr
            image: "qrc:/icons/icons/add_scan_err.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _errForward
            image: "qrc:/icons/icons/err_forward.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _find
            image: "qrc:/icons/icons/find.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        ColorOverlayButton {
            id: _logicAnalyzer
            image: "qrc:/icons/icons/logic_analyzer.svg"
            enabled: _ch.checked
            disabledOverlay: disabledOverlay
            disabledOpacity: disabledOpacity
            normalOverlay: normalOverlay
            normalOpacity: normalOpacity
            hoverOverlay: hoverOverlay
            hoverOpacity: hoverOpacity
            selectedOverlay: selectedOverlay
            selectedOpacity: selectedOpacity
        }
        Item { Layout.fillWidth: true }
    }
}
