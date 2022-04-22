import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatefulWidget {
  MessageItem({
    Key? key,
    required this.isLeft,
    required this.content,
  }) : super(key: key);

  bool isLeft = false;
  String content = "";

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftCenter,
    color: Colors.white,
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );

  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color.fromARGB(255, 225, 255, 199),
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );

  static const textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.normal,
  );

  static const selfBubbleColor = Color.fromRGBO(0xd9, 0xf4, 0xfe, 1.0);
  static const otherBubbleColor = Color.fromRGBO(0xf3, 0xf3, 0xf3, 1.0);

  Widget _createLeft({required String msg}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10),
      alignment: Alignment.topLeft,
      nip: BubbleNip.leftTop,
      color: otherBubbleColor,
      child: Text(
        msg,
        style: textStyle,
      ),
    );
  }

  Widget _createRight({required String msg}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10),
      alignment: Alignment.topRight,
      nip: BubbleNip.rightTop,
      color: selfBubbleColor,
      child: Text(
        msg,
        textAlign: TextAlign.right,
        style: textStyle,
      ),
    );
  }

// Bubble(
//             alignment: Alignment.center,
//             color: Color.fromARGB(255, 237, 249, 255),
//             child: Text('TODAY', textAlign: TextAlign.center, style: textStyle),
//           ),
  @override
  Widget build(BuildContext context) {
    if (widget.isLeft)
      return _createLeft(msg: widget.content);
    else
      return _createRight(msg: widget.content);
  }
}
