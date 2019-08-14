import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1

Dialog {
    property bool autoClose: true


    closePolicy: autoClose ? Popup.CloseOnPressOutside : Popup.NoAutoClose

    anchors.centerIn: parent
    visible: false
    modal: true

    background: Rectangle {
        color: "white"
        anchors.fill: parent
        radius: 5
    }
}
