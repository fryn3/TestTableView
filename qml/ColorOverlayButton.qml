import QtQuick 2.15
import QtGraphicalEffects 1.12

import Theme 12.34

Rectangle {
    id: _myBtn
    property alias image: _image.source
    property alias colorOverlay: _colorOverlay.color
    signal clicked()

    property color disabledOverlay: _defaultColor.disabledOverlay
    property real  disabledOpacity: _defaultColor.disabledOpacity
    property color normalOverlay: _defaultColor.normalOverlay
    property real  normalOpacity: _defaultColor.normalOpacity
    property color hoverOverlay: _defaultColor.hoverOverlay
    property real  hoverOpacity: _defaultColor.hoverOpacity
    property color selectedOverlay: _defaultColor.selectedOverlay
    property real  selectedOpacity: _defaultColor.selectedOpacity

    property var _defaultColor: QtObject {
        property color disabledOverlay: "#00000000"
        property real  disabledOpacity: 0.4
        property color normalOverlay: "#00000000"
        property real  normalOpacity: 1
        property color hoverOverlay: "#99FFFFFF"
        property real  hoverOpacity: 1
        property color selectedOverlay: "#BB000000"
        property real  selectedOpacity: 1
        Component.onCompleted: {
            _myBtn.disabledOverlay = _defaultColor.disabledOverlay
            _myBtn.disabledOpacity = _defaultColor.disabledOpacity
            _myBtn.normalOverlay = _defaultColor.normalOverlay
            _myBtn.normalOpacity = _defaultColor.normalOpacity
            _myBtn.hoverOverlay = _defaultColor.hoverOverlay
            _myBtn.hoverOpacity = _defaultColor.hoverOpacity
            _myBtn.selectedOverlay = _defaultColor.selectedOverlay
            _myBtn.selectedOpacity = _defaultColor.selectedOpacity
        }
    }

    implicitWidth: 34
    implicitHeight: 34
    radius: 4
    color: "transparent"

    Image {
        id: _image
        anchors.centerIn: parent
        smooth: true
        visible: false
    }
    ColorOverlay {
        id: _colorOverlay
        anchors.fill: _image
        source: _image
        color: {
            if (!_myBtn.enabled) {
                return disabledOverlay
            } else if (_mouseArea.containsPress) {
                return selectedOverlay
            } else if (_mouseArea.containsMouse) {
                return hoverOverlay
            } else {
                return normalOverlay
            }
        }

        opacity: {
            if (!_myBtn.enabled) {
                return disabledOpacity
            } else if (_mouseArea.containsPress) {
                return selectedOpacity
            } else if (_mouseArea.containsMouse) {
                return hoverOpacity
            } else {
                return normalOpacity
            }
        }

    }
    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true // try to delete
        onClicked: parent.clicked()
    }
}
