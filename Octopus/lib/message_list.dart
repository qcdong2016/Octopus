import 'package:flutter/material.dart';
import 'package:octopus/message_item.dart';

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  ScrollController _pageScrollerController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        controller: _pageScrollerController,
        padding: const EdgeInsets.all(8),
        children: [
          MessageItem(
            isLeft: true,
            content: "nihao??",
          ),
          MessageItem(
            isLeft: false,
            content: "nihaodadf??",
          ),
        ],
      ),
    );
  }
}
