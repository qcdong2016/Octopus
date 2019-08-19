import QtQuick 2.13
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.13
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import MyPlugins 1.0

import 'Util.js' as Util

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        Item {
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                function updateName() {
                    var c = friendsModel.getByID(chatListModel.currentChat)
                    if (c) {
                        text = c.Nickname + (c.Online ? "" : "[离线]")
                    } else {
                        text = ""
                    }
                }

                Component.onCompleted: {
                    chatListModel.onCurrentChatChanged.connect(updateName)
                    friendsModel.userStatusChanged.connect(updateName)
                }
            }

            Layout.minimumHeight: 20
            Layout.maximumHeight: 20
            Layout.preferredHeight: 20
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            SplitView {
                anchors.fill: parent
                orientation: Qt.Vertical

                Item {
                    id: centerItem
                    Layout.minimumHeight: 400
                    Layout.fillHeight: true

                    MsgList {
                        id: rect1
                    }
                }

                Item {

                    Layout.minimumHeight: 115
                    Layout.maximumHeight: 300
                    Layout.preferredHeight: 135
                    Layout.fillHeight: true

                    ChatInput {
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
