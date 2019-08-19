import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.13
import MyPlugins 1.0

import 'Util.js' as Util

Rectangle {
    Layout.minimumWidth: 150
    Layout.fillHeight: true

    ListView {
        anchors.fill: parent
        delegate: friend
        model: friendsModel
        
        highlightMoveDuration : 0
        highlight: Rectangle { color: "#e0e0e0" }
    }
    
    Component {
        id: friend
        
        Item {
            id:idlistElemnet
            height: 70
            width: parent.width
            
            RowLayout {
                spacing: 6
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40
                    MyImage {
                        anchors.centerIn: parent
                        id: img
                        width: 40
                        height: 40
                        source: Avatar
                        sourceSize: Qt.size(width, height)
                        visible: true
                        displayGray: !Online
                    }
                }
                
                Item {
                    Layout.preferredWidth: 100
                    height: parent.height
                    Text {
                        text: Nickname
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: width/2
                        color: "red"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        visible: unread > 0
                        Text {
                            text: unread
                            color: "white"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    idlistElemnet.ListView.view.currentIndex = index
                    chatListModel.setCurrentChatTo(friendsModel.get(index).ID)
                }
            }
            
        }
    }
}
