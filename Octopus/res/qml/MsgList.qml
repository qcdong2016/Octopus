import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Styles 1.4
import MyPlugins 1.0
import Qt.labs.platform 1.1

Rectangle {
    id: rect1
    anchors.fill: parent
//    color: "lightgray"
    
    ListView {
        id: frame
        clip: true
        anchors.fill: parent
        delegate: bubble
        model: chatListModel.model

        ScrollBar.vertical: ScrollBar {
            id: vbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
//            size:  rect1.height/frame.height
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        Component.onCompleted:  {
            chatListModel.shouldPositionView.connect(shouldPositionView)
        }

        function shouldPositionView() {
            positionViewAtEnd()
        }
    }

    function getSettings() {
        return settings
    }

    FileSaveDialog {
        id:fds
        title: qsTr("Save File")

        property string fileSelected: ""
        property variant selectMsgModel: ""


        onAccepted: {
            fileSelected = fds.fileUrl;
            selectMsgModel.status = "downloading"
            selectMsgModel.absFileName = fileSelected

            var url = "http://" + getSettings().server_ip + "/downFile?file=" + selectMsgModel.url
            var down = chatListModel.createDownloader(fileSelected, url, selectMsgModel)

            down.downloadProgress.connect((down, total) => {
                                              console.log(down/total,down, total )
                                              selectMsgModel.progress = down/total
                                          })
            down.error.connect(() => { selectMsgModel.status = "error" })
            down.finished.connect(() => { selectMsgModel.status = "recved" })
        }

        onRejected: {
        }



        function saveMe(model) {

            if (model.status == "recved" || model.status == "sended") {
                socket.openAndSelectFile(model.absFileName)
                return
            }

            if (model.from == me.userid) {
                return
            }

            selectMsgModel = model

            if (model.status == "ready") {
                this.filename = model.fileName
                fds.open()
            }
        }
    }

    Component {
        id: bubble
        Loader {
            id: itemDisplay
            width: parent.width
            height: children[0].height
            sourceComponent: selector()

            function selector() {
                if (model.type == "image") {
                    if (model.from == me.userid) {
                        return imageMsgRight
                    } else {
                        return imageMsgLeft
                    }
                } else if (model.type == "file") {
                    if (model.from == me.userid) {
                        return fileMsgRight
                    } else {
                        return fileMsgLeft
                    }
                } else {
                    if (model.from == me.userid) {
                        return textMsgRight
                    } else {
                        return textMsgLeft
                    }
                }
            }

            function statusToText(status, progress) {
                if (status == "uploading") {
                    return qsTr("上传中") + Number(progress*100).toFixed() + "%"
                }
                if (status == "sended") {
                    return qsTr("发送成功")
                }
                if (status == "error") {
                    return qsTr("失败")
                }
                if (status == "ready") {
                    return qsTr("等待接收")
                }
                if (status == "downloading") {
                    return qsTr("下载中") + Number(progress*100).toFixed() + "%"
                }
                if (status == "recved") {
                    return qsTr("已接收")
                }
            }

            Component {
                id: fileMsgRight
                Item {
                    id: row1
                    width: parent.width
                    height: children[0].height

                    BorderImage {
                        height: content.height + 30
                        width: content.width + 40
                        border { left: 26; top: 27; right: 27; bottom: 21 }
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: "qrc:/bubble.png"
                        anchors.right: parent.right

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            Rectangle {
                                id: content
                                anchors.centerIn: parent
                                width: 250
                                height: 80

                                RowLayout {
                                    anchors.fill: parent
                                    MyFileIcon {
                                        id: fileicon
                                        source: model.fileName
                                        width: 50
                                        height: 50
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Text {
                                            anchors.centerIn: parent
                                            width: parent.width
                                            text: model.fileName
                                            elide: Text.ElideMiddle
                                        }
                                    }
                                }

                                Text {
                                    text: statusToText(model.status, model.progress)
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fds.saveMe(model)
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: fileMsgLeft
                Item {
                    id: row1
                    width: parent.width
                    height: children[0].height

                    BorderImage {
                        height: content.height + 30
                        width: content.width + 40
                        border { left: 26; top: 27; right: 27; bottom: 21 }
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: "qrc:/bubbleLeft.png"
                        anchors.left: parent.left

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10

                            Rectangle {
                                id: content
                                anchors.centerIn: parent
                                width: 250
                                height: 80

                                RowLayout {
                                    anchors.fill: parent

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Text {
                                            anchors.centerIn: parent
                                            width: parent.width
                                            text: model.fileName
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    MyFileIcon {
                                        id: fileicon
                                        source: model.fileName
                                        width: 50
                                        height: 50
                                    }
                                }

                                Text {
                                    text: statusToText(model.status, model.progress)
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fds.saveMe(model)
                                }
                            }
                        }
                    }
                }
            }



            Component {
                id: imageMsgRight
                Item {
                    id: row1
                    width: parent.width
                    height: children[0].height

                    BorderImage {
                        height: content.height + 30
                        width: content.width + 40
                        border { left: 26; top: 27; right: 27; bottom: 21 }
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: "qrc:/bubble.png"
                        anchors.right: parent.right

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            MyImage1 {
                                id: content
                                anchors.centerIn: parent
                                source: socket.cachedFilePath(model.fileName)
                                width: imageSize.height < 300 ? (imageSize.width > frame.width ? frame.width*0.7 : imageSize.width) : height/imageSize.height * imageSize.width
                                height: imageSize.height < 300 ? (width / imageSize.width * imageSize.height) : 300
                            }

                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    socket.viewImage(socket.cachedFilePath(model.fileName))
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: imageMsgLeft
                Item {
                    id: row1
                    width: parent.width
                    height: children[0].height

                    BorderImage {
                        height: content.height + 30
                        width: content.width + 40
                        border { left: 26; top: 27; right: 27; bottom: 21 }
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: "qrc:/bubbleLeft.png"
                        anchors.left: parent.left

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10

                            MyImage1 {
                                id: content
                                anchors.centerIn: parent
                                source: socket.cachedFilePath(model.fileName)
                                width: imageSize.height < 300 ? (imageSize.width > frame.width ? frame.width*0.7 : imageSize.width) : height/imageSize.height * imageSize.width
                                height: imageSize.height < 300 ? (width / imageSize.width * imageSize.height) : 300
                            }
                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    socket.viewImage(socket.cachedFilePath(model.fileName))
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: textMsgRight
                Item {
                    id: row1
                    width: parent.width
                    height: children[0].height

                    BorderImage {
                        height: content.paintedHeight + 30
                        width: content.paintedWidth + 40
                        border { left: 26; top: 27; right: 27; bottom: 21 }
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: "qrc:/bubble.png"
                        anchors.right: parent.right

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            //TextEdit {
                            TextArea{
                                id: content
                                width: row1.width * 0.8
                                font.pixelSize : 20

                                textFormat :TextEdit.PlainText
                                selectByMouse :true
                                selectByKeyboard :true
                                antialiasing: true
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                text: model.content
                            }
                        }
                    }
                }
            }

            Component {
                id: textMsgLeft
                Item {
                    id: row1
                    width: parent.width
                    height: children[0].height

                    BorderImage {
                        height: content.paintedHeight + 30
                        width: content.paintedWidth + 40
                        border { left: 26; top: 27; right: 27; bottom: 21 }
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: "qrc:/bubbleLeft.png"
                        anchors.left: parent.left

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            //TextEdit {
                            TextArea{
                                id: content
                                width: row1.width * 0.8
                                font.pixelSize : 20

                                textFormat :TextEdit.PlainText
                                selectByMouse :true
                                selectByKeyboard :true
                                antialiasing: true
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                text: model.content
                            }

                        }
                    }
                }
            }
        }
    }


}
