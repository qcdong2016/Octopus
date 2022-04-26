import 'package:bubble/bubble.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:octopus/message_item_file.dart';
import 'package:octopus/wx_expression.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';

class MessageItem extends StatefulWidget {
  MessageItem({
    Key? key,
    required this.msg,
  }) : super(key: key);

  Message msg;

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

  static const selfBubbleColor = Color.fromARGB(255, 183, 232, 250);
  static const otherBubbleColor = Color.fromARGB(255, 188, 250, 236);

  Widget _createFile() {
    return FileMessageItem(
      msg: widget.msg,
    );
  }

  Widget _createImage() {
    var url = "http://${Data.server}/downFile?file=${widget.msg.url}";
    return Container(
      constraints: BoxConstraints(maxHeight: 500, maxWidth: 500),
      child: GestureDetector(
        child: Image(
          image: NetworkImage(url),
        ),
        onTap: () {
          launchUrl(Uri.parse(url));
        },
      ),
    );
  }

  Widget _createLeft({required Widget child}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10),
      alignment: Alignment.topLeft,
      nip: BubbleNip.leftTop,
      color: otherBubbleColor,
      child: child,
    );
  }

  Widget _createRight({required Widget child}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10),
      alignment: Alignment.topRight,
      nip: BubbleNip.rightTop,
      color: selfBubbleColor,
      child: child,
    );
  }

// Bubble(
//             alignment: Alignment.center,
//             color: Color.fromARGB(255, 237, 249, 255),
//             child: Text('TODAY', textAlign: TextAlign.center, style: textStyle),
//           ),
  @override
  Widget build(BuildContext context) {
    late Widget child;
    if (widget.msg.type == "file") {
      child = _createFile();
    } else if (widget.msg.type == "image") {
      child = _createImage();
    } else {
      child = ExpressionText(widget.msg.content, textStyle);
    }

    if (widget.msg.from != Data.data.me.iD)
      return _createLeft(child: child);
    else
      return _createRight(child: child);
  }
}
