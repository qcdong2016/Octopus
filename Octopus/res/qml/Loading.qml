import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1

MyDialog {
    id: dialog
    width: 50
    height: 50
    autoClose: false

    contentItem: Rectangle {
        BusyIndicator{
            anchors.centerIn: parent
            width: 50
            height: 50
        }
    }
}
