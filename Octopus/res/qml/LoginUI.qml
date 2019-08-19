import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.2

import 'Util.js' as Util

Component {

    Item
    {
        id: login_gui

        ColumnLayout
        {
            id: rect1
            width: parent.width/2
            anchors.centerIn: parent

            LineInput
            {
                id: input_acc
                text: settings.userid
                height: 40
                Layout.fillWidth: true
                font_size:height * 0.6
                hint: qsTr("account")
            }
            
            LineInput
            {
                id: input_pwd
                text: settings.password
                height: 40
                Layout.fillWidth: true
                font_size:height * 0.6
                hint: qsTr("password")
            }
            
            Button
            {
                height: 40
                Layout.fillWidth: true
                text: qsTr("login")
                onClicked: {
                    socket.login(input_acc.text, input_pwd.text)
                    socket.addHandler("login", (err, data) => {
                                          if (err) {
                                              socket.close()
                                              return
                                          }

                                          socket.islogin = true
                                          sceneManager.replace(mainui)

                                          me.userid = data.Me.ID

                                          friendsModel.clear()
                                          data.Friends.forEach((v) => {
                                                                    v.unread = 0
                                                                    if (v.Online) {
                                                                        friendsModel.insert(0, v)
                                                                    } else {
                                                                        friendsModel.append(v)
                                                                    }
                                                               })

                                      }, true)
//
                }
            }
        }

        Item {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 50
            height: 50
            Text {
                text: qsTr("options")
                color: "#a0a0a0"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: loginsetting.open()
            }
        }

        Item {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 50
            height: 50
            Text {
                text: qsTr("regist")
                color: "#a0a0a0"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    regist.open()
                }
            }
        }

        MyDialog {
            id: regist
            width: 300; height: 200
            anchors.centerIn: parent

            ColumnLayout
            {
                width: parent.width*0.7
                anchors.centerIn: parent

                LineInput
                {
                    id: nick_input
                    height: 40
                    Layout.fillWidth: true
                    font_size:height * 0.6
                    hint: qsTr("nickname")
                }

                LineInput
                {
                    id: pwd1_input
                    height: 40
                    Layout.fillWidth: true
                    font_size:height * 0.6
                    hint: qsTr("password")
                }

                LineInput
                {
                    id: pwd2_input
                    height: 40
                    Layout.fillWidth: true
                    font_size:height * 0.6
                    hint: qsTr("ensure password")
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: qsTr("cancel")
                        Layout.fillWidth: true
                        onClicked: {
                            regist.close()
                        }
                    }

                    Button {
                        text: qsTr("ok")
                        Layout.fillWidth: true
                        onClicked: {
                            if (pwd1_input.text != pwd2_input.text) {
                                msgBox.show("两次密码输入不一致")
                                return
                            }

                            loading.open()
                            var arg = {
                                nickname: nick_input.text,
                                password: pwd1_input.text,
                                avatar: socket.randomAvatar(nick_input.text),
                            }
                            settings.password = arg.password
                            Util.httpPostJson("/regist", arg, registResp)
                        }

                        function registResp(ok, data) {
                            loading.close()
                            if (!ok) {
                              msgBox.show("注册失败")
                              return
                            }

                            settings.userid = data
                            console.log(data)
                            msgBox.show("你的账号为："+data)
                            regist.close()
                        }
                    }
                }
            }
        }

        MyDialog {
            id: loginsetting
            width: 300; height: 200
            anchors.centerIn: parent

            ColumnLayout
            {
                width: parent.width*0.7
                anchors.centerIn: parent

                LineInput
                {
                    text: settings.server_ip
                    id: ip_input
                    height: 40
                    Layout.fillWidth: true
                    font_size:height * 0.6
                    hint: qsTr("serverip")
                }

                Button {
                    text: "OK"
                    Layout.fillWidth: true
                    onClicked: {
                        settings.server_ip = ip_input.text
                        loginsetting.close()
                    }
                }

                ColumnLayout
                {
                    ExclusiveGroup {
                        id: exclusive
                        onCurrentChanged: {
                            socket.setLanguageStatic(current.text)
                        }
                    }

                    RadioButton {
                        text: "zh_CN"
                        exclusiveGroup: exclusive
                        Component.onCompleted: {
                            checked = socket.language == text
                        }
                    }

                    RadioButton {
                        text: "en_US"
                        exclusiveGroup: exclusive
                        Component.onCompleted: {
                            checked = socket.language == text
                        }
                    }
                }
            }
        }
    }
}
