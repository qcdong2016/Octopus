import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({Key? key}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final List<String> _list = [];

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: 20,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF2F2F2),
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
