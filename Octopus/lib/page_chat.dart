import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/avatar.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/friend_list.dart';
import 'package:octopus/wx_expression.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popover/popover.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:intl/intl.dart';

import 'chat_input.dart';
import 'line_input.dart';
import 'message_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    Client.instance.addHandler("chat.text", (err, data) {
      Message msg = Message().fromJson(data);
      Data.data.addMessage(msg);
    }, false);

    Client.instance.addHandler("chat.file", (err, data) {
      Message msg = Message().fromJson(data);
      Data.data.addMessage(msg);
    }, false);

    Client.instance.addHandler("friendOnline", (err, data) {
      Data.data.setUserOnline(User().fromJson(data));
    }, false);

    Client.instance.addHandler("friendOffline", (err, data) {
      Data.data.setUserOffline(data);
    }, false);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showConfig() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var nickctrl = TextEditingController(text: Data.data.me.nickname);
          Color pickerColor = Color(0xff443a49);
          Color currentColor = Color(0xff443a49);

          return AlertDialog(
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Center(
                    child: Text("我的资料"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Avatar(user: Data.data.me),
                  LineInput(
                    hint: '昵称',
                    icon: Icons.people,
                    controller: nickctrl,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget createLeft() {
    if (Data.data.chatTarget.iD == 0) {
      return const Center(
        child: Text("Octopus"),
      );
    }

    var input = ChatInput();
    return Column(
      children: [
        Container(
          height: 30,
          color: Color.fromARGB(255, 243, 243, 243),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text(
                  Data.data.chatTarget.nickname +
                      (Data.data.chatTarget.online ? "[在线]" : "[离线]"),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 20,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        showConfig();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: MessageList(),
        ),
        Container(
          height: 1,
          color: Colors.grey,
        ),
        Container(
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Builder(
                builder: (context1) {
                  return IconButton(
                    icon: const Icon(Icons.tag_faces),
                    iconSize: 30,
                    color: Colors.grey,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      showPopover(
                        context: context1,
                        barrierColor: Colors.transparent,
                        transitionDuration: const Duration(milliseconds: 100),
                        bodyBuilder: (context) => WeChatExpression((e) {
                          input.controller.text += "[${e.name}]";
                        }),
                        direction: PopoverDirection.bottom,
                        width: 500,
                        height: 300,
                        arrowHeight: 15,
                        arrowWidth: 30,
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.cut),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  Directory tempDir = await getApplicationDocumentsDirectory();
                  var date = DateFormat("yyyy-MM-dd_HHmmss", 'en_US')
                      .format(DateTime.now());

                  File file =
                      File('${tempDir.path}/Octopus/ScreenShot/SC_$date.jpg');
                  file.createSync(recursive: true);

                  CapturedData? capturedData =
                      await ScreenCapturer.instance.capture(
                    mode: CaptureMode.region, // screen, window
                    imagePath: file.path,
                  );

                  if (capturedData == null) {
                    SmartDialog.showToast("错误");
                  } else {
                    Client.sendFile("image", file.path);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.crop_original),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'png', 'gif'],
                  );
                  if (result != null && result.files.single.path != null) {
                    Client.sendFile("image", result.files.single.path!);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.folder_open),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null && result.files.single.path != null) {
                    Client.sendFile("file", result.files.single.path!);
                  }
                },
              ),
            ],
          ),
        ),
        Container(
          height: 150,
          child: input,
        )
        // ,
        // MessageList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 150,
            child: FriendList(),
          ),
          Container(
            width: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: EventWidget(
              buidler: (context) => createLeft(),
              event: Data.data,
            ),
          ),
        ],
      ),
    );
  }
}
