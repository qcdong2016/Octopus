import 'package:flutter/material.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/friend_list.dart';

import 'chat_input.dart';
import 'message_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    Client.instance.addHandler("chat.text", (err, data) {
      Message msg = Message.fromJson(data);
      Data.data.addMessage(msg);
    }, false);

    Client.instance.addHandler("chat.file", (err, data) {
      Message msg = Message.fromJson(data);
      Data.data.addMessage(msg);
    }, false);

    Client.instance.addHandler("friendOnline", (err, data) {
      Data.data.setUserOnline(User().fromJson(data));
    }, false);

    Client.instance.addHandler("friendOffline", (err, data) {
      Data.data.setUserOffline(data);
    }, false);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 150,
            child: FriendList(),
          ),
          Container(
            width: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: MessageList(),
                ),
                Container(
                  height: 1,
                  color: Colors.grey,
                ),
                Container(
                  height: 40,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: Icon(Icons.tag_faces),
                        iconSize: 30,
                        color: Colors.grey,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.crop_original),
                        iconSize: 30,
                        color: Colors.grey,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.folder_open),
                        iconSize: 30,
                        color: Colors.grey,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  child: ChatInput(),
                )
                // ,
                // MessageList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
