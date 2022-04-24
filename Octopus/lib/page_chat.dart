import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/friend_list.dart';
import 'package:system_tray/system_tray.dart';

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
      Message msg = Message.fromJson(data);
      Data.data.addMessage(msg);
    }, false);

    Client.instance.addHandler("chat.file", (err, data) {
      Message msg = Message.fromJson(data);
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
              IconButton(
                icon: Icon(Icons.tag_faces),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.cut),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  if (Platform.isMacOS) {
                    String imageName = '/Users/mac/_octopus_auto.jpg';

                    List<String> arguments = [
                      "-i",
                      "-r",
                      "-u",
                      // "-U",
                      imageName,
                    ];

                    var res = await Process.run(
                      '/usr/sbin/screencapture',
                      arguments,
                    );

                    if (res.exitCode != 0) {
                      SmartDialog.showToast(res.stderr);
                    } else {
                      // sendFile("image", imageName);
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.crop_original),
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
                icon: Icon(Icons.folder_open),
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
          child: ChatInput(),
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
