import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';

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
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event.runtimeType == KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
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
              Data.data.addMessage(Message.fromJson(data));
            },
          );
        }
      },
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.multiline,
        maxLines: 20,
        decoration: const InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(3),
        ),
        onSubmitted: (text) {
          print(text);
        },
      ),
    );
    // DropTarget(
    //   onDragDone: (detail) {
    //     setState(() {
    //       print(detail.files[0]);
    //     });
    //   },
    //   onDragEntered: (detail) {
    //     setState(() {
    //       _dragging = true;
    //     });
    //   },
    //   onDragExited: (detail) {
    //     setState(() {
    //       _dragging = false;
    //     });
    //   },
    //   child: Container(
    //     height: 200,
    //     width: 200,
    //     color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
    //     child: _list.isEmpty
    //         ? const Center(child: Text("Drop here"))
    //         : Text(_list.join("\n")),
    //   ),
    // );
  }
}
