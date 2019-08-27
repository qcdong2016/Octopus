import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1
import Qt.labs.platform 1.1
import MyPlugins 1.0

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
        signal userStatusChanged(int userid)


        function getNameByID(id) {
            var c = getByID(id)
            if (c) {
                return c.Nickname
            }

            return ""
        }

        function getByID(id) {
            for (var i =0; i < count; i++) {
                var v = get(i)
                if (v.ID == id) {
                    return v
                }
            }
        }

        function bringToTop(id) {
            for (var i =0; i < count; i++) {
                var v = get(i)
                if (v.ID == id) {
                    move(i, 0, 1)
                    break
                }
            }
        }

        function friendOnline(err, msg) {
            msg.unread = 0

            var friend = getByID(msg.ID)

            if (friend) {
                friend.Online = true
                userStatusChanged(msg.ID)
            } else {
                append(msg)
            }
        }

        function friendOffline(err, msg) {
            var friend = getByID(msg)

            if (friend) {
                friend.Online = false
                userStatusChanged(msg)
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

        Component {
            id: listMod
            ListModel{
            }
        }

        Component {
            id: myhttp
            Http {

            }
        }

        function createDownloader(fileurl, url, parent) {
            var h = myhttp.createObject(parent)
            h.url = url
            h.download(fileurl)
            return h
        }

        function createUploader(fileurl, url, parent) {
            var h = myhttp.createObject(parent)
            h.url = url
            h.upload(fileurl)
            return h
        }

        function getHistory(id) {
            var list = chatHistory[id]
            if (list == null) {
                list = listMod.createObject(this)
                chatHistory[id] = list
            }
            return list
        }

        function appendMsg(msg) {
            return doAppendMsg(msg.To, msg)
        }


        function doAppendMsg(target, msg) {
            friendsModel.bringToTop(target)

            var shouldNotify = false
            if (target == currentChat) {
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
            var msgObj = {}

            msgObj.from = msg.From
            msgObj.to = msg.To
            msgObj.type = msg.Type
            msgObj.content = msg.Content || ""
            msgObj.progress = (msg.Progress == null) ? 0 : msg.Progress
            msgObj.status = msg.Status || ""
            msgObj.url = msg.URL || ""
            msgObj.fileName = msg.FileName || ""
            msgObj.absFileName = ""

            list.append(msgObj)
            if (list.count > 100) {
                list.slice(1);
            }

            return list.get(list.count - 1)
        }

        function setCurrentChatTo(id) {
            currentChat = id
//            model.clear()
            model = getHistory(id)

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

        function onRecvFileMessage(err, msg) {
            doAppendMsg(msg.From, {
                            From: msg.From,
                            To: msg.To,
                            Type: "file",
                            FileName: msg.FileName,
                            URL: msg.URL,
                            Status: "ready",
                        })
        }

        Component.onCompleted: {
            socket.addHandler("chat.text", onRecvTextMessage)
            socket.addHandler("chat.image", onRecvImageMessage)
            socket.addHandler("chat.file", onRecvFileMessage)
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
