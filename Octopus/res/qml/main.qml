import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1
import Qt.labs.platform 1.1

import QtQml.Models 2.1

Window {
    id: window
    visible: true
    width: 761
    height: 759
    title: qsTr("Octopus")
    minimumHeight: 737
    minimumWidth: 761

    onClosing: {
        close.accepted = false;
        window.hide()
    }

    SystemTrayIcon {
        id: tray
        visible: true
        icon.source: "qrc:/icon_64x64.png"

        onMessageClicked: {
            window.requestActivate();
            window.raise()
            window.show();
        }

        onActivated: {
            window.requestActivate();
            window.raise()
            window.show();
        }

        menu: Menu {
               id: menu1
               MenuItem {
                   text: qsTr("Quit")
                   onTriggered: Qt.quit()
               }
           }
    }

    MsgBox {
        id: msgBox
    }

    Settings {
        id: settings
        property string server_ip: "192.168.2.179:7456"
        property int userid: 0
        property string password: ""
    }

    Socket {
        id: socket
    }

    Item {
        id: me
        property int userid: 0
    }

    ListModel {
        id: friendsModel
//        ListElement {
//            unread: 99
//        }

        function getByID(id) {
            for (var i =0; i < count; i++) {
                var v = get(i)
                if (v.ID == id) {
                    return v
                }
            }
        }

        function friendOnline(err, msg) {
            msg.unread = 0
            append(msg)
        }

        function friendOffline(err, msg) {
            for (var i =0; i < count; i++) {
                if (get(i).ID == msg) {
                    remove(i)
                    break
                }
            }

            if (count == 0) {
                chatListModel.setCurrentChatTo(0)
            }
        }

        Component.onCompleted: {
            socket.addHandler("friendOffline", friendOffline)
            socket.addHandler("friendOnline", friendOnline)
        }
    }

    Item {
        id: chatListModel
        signal shouldPositionView()

        property int currentChat: 0
        property var chatHistory: { "foo": 10, "bar": 20 }

        property var model: ListModel{}

        function getHistory(id) {
            var list = chatHistory[id]
            if (list == null) {
                list = []
                chatHistory[id] = list
            }
            return list
        }

        function appendMsg(msg) {
            doAppendMsg(msg.To, msg)
        }

        function doAppendMsg(target, msg) {
            var shouldNotify = false
            if (target == currentChat) {
                model.append(msg)
                shouldPositionView()

                if (window.visibility == Window.Minimized || window.visibility == Window.Hidden) {
                    shouldNotify = true;
                }
            } else {
                var friend = friendsModel.getByID(target)
                friend.unread++
                shouldNotify = true;
            }

            if (shouldNotify) {
                var friend = friendsModel.getByID(target)
                if (msg.Type == "text") {
                    tray.showMessage(friend.Nickname, msg.Content)
                } else {
                    tray.showMessage(friend.Nickname, "[图片]")
                }
            }

            var list = getHistory(target)
            list.push(msg)
            if (list.length > 100) {
                list.slice(1);
            }
        }

        function setCurrentChatTo(id) {
            currentChat = id
            model.clear()
            getHistory(id).forEach((v) => {
                                       model.append(v)
                                   })
            shouldPositionView()
            var fr = friendsModel.getByID(currentChat)
            if (fr) {
                fr.unread = 0
            }
        }

        function onRecvTextMessage(err, msg) {
            doAppendMsg(msg.From, {
                            From: msg.From,
                            To: msg.To,
                            Type: "text",
                            FileName: "",
                            Content: socket.base64decode(msg.Content),
                        })
        }

        function onRecvImageMessage(err, msg) {
            doAppendMsg(msg.From, {
                            From: msg.From,
                            To: msg.To,
                            Type: "image",
                            FileName: msg.FileName,
                            Content: "",
                        })
        }

        Component.onCompleted: {
            socket.addHandler("chat.text", onRecvTextMessage)
            socket.addHandler("chat.image", onRecvImageMessage)
        }
    }

    Loading {
        id: loading
    }

    StackView {
        id: sceneManager;
        anchors.fill:parent

        initialItem: loginui
    }

    LoginUI {
        id: loginui
    }

    MainUI {
        id: mainui
    }


}
