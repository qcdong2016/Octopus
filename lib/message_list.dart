import 'package:flutter/material.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/message_item.dart';

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    return EventWidget(
      event: Data.data.msgCurrentEvent,
      buidler: (context) {
        var list = Data.data.getMessage(Data.data.chatTarget.iD);

        return ListView.builder(
          controller: Data.data.pageScrollerController,
          itemCount: list.length,
          itemBuilder: (context, index) {
            var one = list[index];
            return MessageItem(msg: one);
          },
        );
      },
    );
  }
}
