import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:octopus/event/event.dart';
import 'package:octopus/event/event_widget.dart';

import 'data.dart';
import 'friend_item.dart';

class FriendList extends StatefulWidget {
  FriendList({Key? key}) : super(key: key);

  @override
  _FriendList createState() {
    return _FriendList();
  }
}

class _FriendList extends State<FriendList> {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: EventWidget(
        buidler: (context) {
          return ListView.builder(
            controller: Data.data.friendsScrollerController,
            itemCount: Data.data.friends.length,
            itemBuilder: (BuildContext context, int index) {
              var user = Data.data.friends[index];
              return EventWidget(
                buidler: ((context) => FriendItem(user: user)),
                event: MultiEvent(list: [user, Data.data]),
              );
            },
          );
        },
        event: Data.data,
      ),
    );
  }
}
