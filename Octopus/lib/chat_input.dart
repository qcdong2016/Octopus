import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:flutter/services.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({Key? key}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final List<String> _list = [];
  TextEditingController _controller = TextEditingController();

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) async {
        var typ = event.runtimeType.toString();
        if (typ != "RawKeyDownEvent") {
          return;
        }

        if (event.logicalKey == LogicalKeyboardKey.enter) {
          var msg = utf8.encode(_controller.text);
          var msg1 = base64Encode(msg);
          Client.send(
            "chat.text",
            {
              "To": Data.data.chatTarget.iD,
              "Content": msg1,
            },
            cb: (err, data) {
              _controller.text = "";
              Data.data.addMessage(Message().fromJson(data));
            },
          );
        }

        if (event.logicalKey == LogicalKeyboardKey.keyV &&
            (event.isControlPressed || event.isMetaPressed)) {
          // 剪切板
        }
      },
      child: DropTarget(
        onDragDone: (detail) {
          setState(() {
            var file = detail.files[0];
            Client.sendFile("file", file.path);
          });
        },
        onDragEntered: (detail) {
          setState(() {
            _dragging = true;
          });
        },
        onDragExited: (detail) {
          setState(() {
            _dragging = false;
          });
        },
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.multiline,
          maxLines: 20,
          decoration: InputDecoration(
            filled: true,
            hoverColor: Colors.transparent,
            contentPadding: EdgeInsets.all(3),
            fillColor:
                _dragging ? Color.fromARGB(255, 184, 238, 255) : Colors.white,
          ),
        ),
      ),
    );
  }
}
