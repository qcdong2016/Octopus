import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 1.4
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.13


Component{
    Item {

        SplitView {
            anchors.fill: parent
            orientation: Qt.Horizontal

            FriendList {
                Layout.maximumWidth: 250
            }
            
            Rectangle {
                Layout.minimumWidth: 450
                Layout.fillHeight: true
                ChatForm {
                    id: chatform
                    visible: chatListModel.currentChat != 0
                }

                Rectangle {
                    id: nochat
                    anchors.centerIn: parent
                    visible: chatListModel.currentChat == 0
                    Text {
                        anchors.centerIn: parent
                        text: "Octopus"
                    }
                }
            }
        }
    }
}
