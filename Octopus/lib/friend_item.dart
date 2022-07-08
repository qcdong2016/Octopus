import 'package:flutter/material.dart';
import 'package:octopus/data.dart';
import 'package:badges/badges.dart';
import 'package:octopus/event/event_widget.dart';

import 'avatar.dart';

class FriendItem extends StatefulWidget {
  User _user = User();

  FriendItem({Key? key, required User user}) : super(key: key) {
    _user = user;
  }

  @override
  _FriendItem createState() {
    return _FriendItem();
  }
}

class _FriendItem extends State<FriendItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Data.data.chatTarget = widget._user;
      },
      child: Container(
        height: 50,
        color: widget._user.iscurrent ? Colors.grey.shade300 : Colors.white,
        child: Row(
          children: [
            const SizedBox(width: 5),
            Avatar(
              user: widget._user,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                height: 53.5,
                child: Text(
                  widget._user.nickname,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            Badge(
              badgeContent: Text(widget._user.unread.toString()),
              showBadge: widget._user.unread > 0,
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
