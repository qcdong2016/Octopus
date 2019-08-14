import QtQuick 2.13
import QtQuick.Window 2.13
import MyPlugins 1.0

MyQuickWin {
    id: mainwindow
    visible: true
    width: Math.min(Math.max(image.width+100, 400), Screen.desktopAvailableWidth)
    height: Math.min(Math.max(image.height+100, 300), Screen.desktopAvailableHeight)

    title: qsTr("Image Preview")

    property string source: ""

    color: "#333333"

    Item {
        id:imageDisplay

        anchors.fill: parent

        MyImage1 {
            id: image
            source: mainwindow.source
            width: imageSize.width
            height: imageSize.height

            x: imageDisplay.width /2 - width/2
            y: imageDisplay.height /2 - height/2
        }

        MouseArea{
            anchors.fill: parent
            onWheel: {
                var scaleBefore = image.scale;
                image.scale += image.scale * wheel.angleDelta.y / 120 / 10;
            }

            drag.target: image;
            drag.axis: Drag.XAxis | Drag.YAxis;
        }
    }
}
