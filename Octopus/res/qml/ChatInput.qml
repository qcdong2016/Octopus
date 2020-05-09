import QtQuick 2.13
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import MyPlugins 1.0


import 'Util.js' as Util

Item {
    id: chat
    
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

        function sendFile(fileurl) {

            var obj = chatListModel.appendMsg({
                                        From: me.userid,
                                        To: chatListModel.currentChat,
                                        Type: "file",
                                        FileName: Util.getBaseName(fileurl),
                                    })

            var url = "http://" + settings.server_ip + "/upFile?from="+me.userid + "&to=" + chatListModel.currentChat
            var up = chatListModel.createUploader(fileurl, url, obj)
            obj.status = "uploading"
            up.uploadProgress.connect((send, total)=> {
                                          if (total != 0) {
                                              obj.progress = send/total
                                          }
                                      })
            up.finished.connect(()=> { obj.status = "sended"; obj.absFileName = fileurl })
            up.error.connect(()=> { obj.status = "error" })
        }
        
        function pasteUrls(urls) {
            var f = urls[0];

            if (!socket.exists(f)) {
                return false
            }
            
            if (socket.sizeofFile(f) > 10485760) {
//                msgBox.show("只能发送10M以下的文件")
                sendFile(f)
                return true
            }
            var ext = Util.getFileExt(f)
            if (ext == "png" || ext == "gif" || ext == "jpg") {
                var newName = socket.cacheFile(f)
                sendImage(newName)
                return true;
            } else {
                sendFile(f)
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
    
    FileDialog {
        id:fds
        title: "选择图片"
        folder: shortcuts.desktop
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        onAccepted: {
            let url = fds.fileUrl;
            filter.pasteUrls([url.toString()])
        }

        onRejected: {
        }

        function openImages() {
            this.nameFilters = ["图片文件 (*.png *.jpg *.jpeg)"]
            this.open()
        }
        function openFiles() {
            this.nameFilters = ["文件 (*.*)"]
            this.open()
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
                    onClicked: {
                        fds.openImages()
                    }
                }
                
                MyToolButton {
                    source: "qrc:/icon/floder.png"
                    onClicked: {
                        fds.openFiles()
                    }
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
