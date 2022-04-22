import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/message_item.dart';

import 'package:url_launcher/url_launcher.dart';

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
      child: EventWidget(
        event: Data.data,
        buidler: (context) {
          var list = Data.data.getMessage(Data.data.chatTarget.iD);

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              var one = list[index];
              return MessageItem(
                isLeft: one.from != Data.data.me.iD,
                content: one.content,
              );
            },
          );
        },
      ),
    );
  }
}
