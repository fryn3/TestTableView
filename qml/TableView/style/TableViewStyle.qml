/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 1.4

import ".." as Table

BasicTableViewStyle {
    id: root

    readonly property Item control: __control

    backgroundColor: "#414141"
    alternateBackgroundColor: "#414141"
    textColor: "#C1C0C0"

    headerDelegate: Rectangle {
        height: 22
        color: "#535353"

        Text {
            id: textItem
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: styleData.textAlignment
            anchors.leftMargin: horizontalAlignment === Text.AlignLeft ? 12 : 1
            anchors.rightMargin: horizontalAlignment === Text.AlignRight ? 8 : 1
            text: styleData.value
            elide: Text.ElideRight
            color: textColor
            renderType: Text.NativeRendering
        }
        Rectangle {
            width: 1
            height: parent.height - 6
            y: 3
            color: "#383838"
        }
    }

    numColumnDelegate: Rectangle {
        height: 32
        color: "#535353"

        Text {
            id: textItem2
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.leftMargin: horizontalAlignment === Text.AlignLeft ? 12 : 1
            anchors.rightMargin: horizontalAlignment === Text.AlignRight ? 8 : 1
            text: styleData.row + 1
            elide: Text.ElideRight
            color: textColor
            renderType: Text.NativeRendering
        }
        Rectangle {
            height: 1
            width: parent.width - 6
            x: 3
            color: "#383838"
        }
    }

    rowDelegate: Rectangle {
        height: 32

        opacity: 0.06
        property color selectedColor: "#ffffff"
        color: styleData.selected ? selectedColor :
                                    !styleData.alternate ? alternateBackgroundColor : backgroundColor
    }

    itemDelegate: Item {
        height: 32

        property int implicitWidth: label.implicitWidth + 20

        Text {
            id: label
            objectName: "label"
            width: parent.width - x - (horizontalAlignment === Text.AlignRight ? 8 : 1)
            x: (styleData.hasOwnProperty("depth") && styleData.column === 0) ? 0 :
                                                                               horizontalAlignment === Text.AlignRight ? 1 : 8
            horizontalAlignment: styleData.textAlignment
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            elide: styleData.elideMode
            text: styleData.value !== undefined ? styleData.value.toString() : ""
            color: styleData.textColor
            renderType: Text.NativeRendering
        }

        Rectangle {
            anchors {
                fill: parent
                rightMargin: -1
                bottomMargin: -1
            }
            color: "transparent"
            border.color: "#2E2D2D"
        }
    }

    scrollBarBackground: Rectangle {
        implicitWidth: 7
        implicitHeight: 7
        color: "#535353"
        Rectangle {
            anchors {
                fill: parent
                topMargin: styleData.horizontal ? 2 : 3
                bottomMargin: styleData.horizontal ? 2 : 3
                leftMargin: styleData.horizontal ? 3 : 2
                rightMargin: styleData.horizontal ? 3 : 2
            }
            color: "#C1C0C0"
            opacity: 0.3
        }
    }

    handle: Item {
        implicitWidth: 7
        implicitHeight: 7
        Rectangle {
            anchors {
                fill: parent
                topMargin: styleData.horizontal ? 2 : 3
                bottomMargin: styleData.horizontal ? 2 : 3
                leftMargin: styleData.horizontal ? 3 : 2
                rightMargin: styleData.horizontal ? 3 : 2
            }
            color: "#C1C0C0"
        }
    }
    corner:Rectangle {
        implicitWidth: 7
        implicitHeight: 7
        color: "#535353"
    }
    decrementControl: null
    incrementControl: null
}
