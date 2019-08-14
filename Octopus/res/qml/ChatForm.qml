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
//    Popup {
//        id: facePick
//        width: 400
//        height: 300
//        visible: false
//    }

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
            id: chat
            Layout.minimumHeight: 115
            Layout.maximumHeight: 300
            Layout.preferredHeight: 135
            Layout.fillHeight: true

            EventFilter
            {
                id: filter
                filterEnterEnabled: true
                filterPasteEnabled: true
                onEnterPressed:
                {
                    if (!edit.text) {
                        msgBox.show("不可以发送空消息")
                        return
                    }

                    console.log(edit.text)
                    var content = socket.base64encode(edit.text)
                    edit.text = ""

                    socket.send("chat.text", {
                                    To: chatListModel.currentChat,
                                    Content: content,
                                }, (err, msg)=> {
                                    if (!err) {
                                        chatListModel.appendMsg({
                                                                    From: msg.From,
                                                                    To: msg.To,
                                                                    Type: "text",
                                                                    FileName: "",
                                                                    Content: socket.base64decode(msg.Content),
                                                                })
                                    }
                                })
                }

                function sendImage(imagePath) {
                    socket.sendFile("chat.image", {
                                    To: chatListModel.currentChat,
                                    FileName: Util.getBaseName(imagePath),
                                },
                                imagePath,
                                (err, msg)=> {
                                    if (!err) {
                                        chatListModel.appendMsg({
                                                                    From: msg.From,
                                                                    To: msg.To,
                                                                    Type: "image",
                                                                    FileName: Util.getBaseName(imagePath),
                                                                    Content: "",
                                                                })
                                    }
                                })
                }

                function pasteUrls(urls) {
                    var f = urls[0];

                    if (socket.sizeofFile(f) > 10485760) {
                        msgBox.show("只能发送10M以下的文件")
                        return false
                    }
                    var ext = Util.getFileExt(f)
                    if (ext == "png" || ext == "gif" || ext == "jpg") {
                        var newName = socket.cacheFile(f)
                        sendImage(newName)
                        return true;
                    }
                }

                onImagePaste: {

                    sendImage(imagePath)
                }

                onFilesPaste: {
                    pasteUrls(files)
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 2
                Item {
                    Layout.fillHeight: true
                    Layout.maximumHeight: 30
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: parent.width
                    Row {
                        anchors.fill: parent
                        spacing: 15

                        MyToolButton {
                            id: faceBtn
                            source: "qrc:/icon/face.png"
                            onClicked: {
                            }
                        }

                        MyToolButton {
                            source: "qrc:/icon/cut.png"
                        }

                        MyToolButton {
                            source: "qrc:/icon/image.png"
                        }

                        MyToolButton {
                            source: "qrc:/icon/floder.png"
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredHeight: 70
                    Layout.preferredWidth: parent.width
                    TextEdit {
                        id: edit
                        text: ""
                        textFormat: TextEdit.PlainText
                        anchors.fill: parent
                        selectByMouse : true
                        wrapMode: TextEdit.Wrap

                        Component.onCompleted: {

                            filter.source = edit
                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            onDropped: {
                                if (drop.hasUrls) {
                                    if (filter.pasteUrls(drop.urls)) {
                                        drop.acceptProposedAction();
                                    }
                                } else {
                                    edit.append(drop.text)
                                    drop.acceptProposedAction();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
