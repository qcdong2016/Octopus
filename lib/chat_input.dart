import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/pb/msg.pb.dart';
import 'package:path/path.dart' as path;
import 'package:fixnum/fixnum.dart' as fixnum;

class ChatInput extends StatefulWidget {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  ChatInput({Key? key}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final List<String> _list = [];

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

        if (event.logicalKey == LogicalKeyboardKey.enter &&
            !event.isShiftPressed) {
          var text = widget.controller.text.trim();
          if (text != "") {
            // var msg = utf8.encode(text);
            // var msg1 = base64Encode(msg);

            var resp = await ChatApi(Client.instance).send(
                null,
                Msg(
                  to: fixnum.Int64(Data.data.chatTarget.iD),
                  text: TextMsg(text: text),
                ));
            widget.controller.text = "";
            Data.data.addMessage(resp);
          }
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

            var ext = path.extension(file.path).toLowerCase();
            if (ext == '.jpg' ||
                ext == ".jpeg" ||
                ext == ".png" ||
                ext == ".gif" ||
                ext == ".webp") {
              Client.sendFile(file.path, true);
            } else {
              Client.sendFile(file.path, false);
            }
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
          controller: widget.controller,
          keyboardType: TextInputType.multiline,
          maxLines: 20,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            filled: true,
            hoverColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(3),
            fillColor: _dragging
                ? const Color.fromARGB(255, 184, 238, 255)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
