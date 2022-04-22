import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
  ScrollController _pageScrollerController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: ListView.builder(
        controller: _pageScrollerController,
        itemCount: Data.data.friends.length,
        itemBuilder: (BuildContext context, int index) {
          return FriendItem(index: Data.data.friends[index]);
        },
      ),
    );
  }
}
