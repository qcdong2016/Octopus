import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/friend_list.dart';
import 'package:octopus/wx_expression.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popover/popover.dart';
import 'package:screen_capturer/screen_capturer.dart';

import 'chat_input.dart';
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

  Widget createLeft() {
    if (Data.data.chatTarget.iD == 0) {
      return const Center(
        child: Text("Octopus"),
      );
    }

    var input = ChatInput();
    return Column(
      children: [
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
                  Directory tempDir = await getTemporaryDirectory();
                  String imageName = '${tempDir.path}/_octopus_auto.jpg';

                  CapturedData? capturedData =
                      await ScreenCapturer.instance.capture(
                    mode: CaptureMode.region, // screen, window
                    imagePath: imageName,
                  );

                  if (capturedData == null) {
                    SmartDialog.showToast("错误");
                  } else {
                    Client.sendFile("image", imageName);
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
