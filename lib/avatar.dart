import 'package:flutter/material.dart';

import 'data.dart';

// fonts:/#8b82a2/#7670bd/Q
class Avatar extends StatefulWidget {
  String _name = "?";
  Color _bgColor = Color.fromARGB(255, 255, 255, 255);
  Color _fgColor = Color.fromARGB(255, 255, 255, 255);
  double size = 20;

  Avatar({Key? key, required User user}) : super(key: key) {
    var arr = user.avatar.split("/");
    if (user.online) {
      _bgColor = Color(int.parse(arr[1].replaceAll("#", "0x"))).withAlpha(255);
      _fgColor = Color(int.parse(arr[2].replaceAll("#", "0x"))).withAlpha(255);
    } else {
      _bgColor = Colors.grey;
      _fgColor = Colors.grey.shade600;
    }

    _name = arr[3];
  }

  @override
  State<Avatar> createState() {
    return _AvatarState();
  }
}

class _AvatarState extends State<Avatar> {
  List list = [];

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: widget._bgColor,
      radius: widget.size,
      child: Text(
        widget._name,
        style: TextStyle(
          fontSize: widget.size + 6, // 文字大小
          color: widget._fgColor, // 文字颜色
        ),
      ),
    );
  }
}
