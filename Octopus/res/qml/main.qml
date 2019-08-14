import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1

import QtQml.Models 2.1

Window {
    id: window
    visible: true
    width: 761
    height: 759
    title: qsTr("Octopus")
    minimumHeight: 737
    minimumWidth: 761

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
            if (target == currentChat) {
                model.append(msg)
                shouldPositionView()
            } else {
                friendsModel.getByID(target).unread++
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
