import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1




MyDialog {
    id: dialog
    property string backGroundColor: "white"

    function show(text) {
        console.log(text)
        msg.text = text
        open()
    }

    width: {
        if(msg.implicitWidth < 100 || msg.implicitWidth == 100)
            return 100;
        else
            return msg.implicitWidth > 300 ? 300 + 24 : (msg.implicitWidth + 24);
    }
    height: msg.implicitHeight + 24 + 100

    contentItem: Rectangle {
        border.color: backGroundColor
        color: backGroundColor
        Text {
            id: msg
            anchors.fill: parent
            anchors.centerIn: parent
            font.family: "Microsoft Yahei"
            color: "gray"
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
    footer: Rectangle {
        width: msg.width
        height: 50
        border.color: backGroundColor
        color: backGroundColor
        radius: 5
        Button {
            anchors.centerIn: parent
            width: 80
            height: 30
            background: Rectangle {
                anchors.centerIn: parent
                width: 80
                height: 30
                radius: 5
                border.color: "#0f748b"
                border.width: 2
                color: backGroundColor
                Text {
                    anchors.centerIn: parent
                    font.family: "Microsoft Yahei"
                    font.bold: true
                    color: "#0f748b"
                    text: "OK"
                }
            }
            onClicked: {
                dialog.close();
            }
        }
    }
}
