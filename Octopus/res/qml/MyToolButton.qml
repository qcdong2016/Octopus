import QtQuick 2.13
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.13

import 'Util.js' as Util

Rectangle {
    property alias source: img.source
    signal clicked()

    height: parent.height
    width: parent.height

    Image {
        id: img
        anchors.centerIn: parent
        width: parent.width - 4
        height: parent.height - 4
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            parent.color = "#F1F1F1"
        }
        onExited: {
            parent.color = "#FFFFFF"
        }
        onPressed: {
            parent.color = "#E6E6E6"
        }
        onReleased: {
            parent.color = "#E6E6E6"
        }

        onClicked: {
            parent.clicked()
        }
    }
}
