import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:octopus/client.dart' as Octopus;
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
          Octopus.Client.send(
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
      child: DropTarget(
        onDragDone: (detail) {
          setState(() async {
            var from = Data.data.me.iD;
            var to = Data.data.chatTarget.iD;
            var url = "http://${Data.server}/upFile?from=${from}&to=${to}";
            var file = detail.files[0];

            var req = MultipartRequest("POST", Uri.parse(url));

            var mf = MultipartFile("file", file.openRead(), await file.length(),
                filename: file.name);
            req.files.add(mf);

            var resp = await req.send();
            var result = await resp.stream.bytesToString();

            print(result);
            // http.MultipartFile

            // var formData = FormData.fromMap({
            //   'file': await MultipartFile.fromFile(detail.files[0].path),
            // });
            // var response = await Dio().post('/upFile', data: formData);
            // // var file = detail.files[0].readAsBytes();
            // print(response);
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
            contentPadding: EdgeInsets.all(3),
            fillColor:
                _dragging ? Color.fromARGB(255, 184, 238, 255) : Colors.white,
          ),
        ),
      ),
    );
  }
}
