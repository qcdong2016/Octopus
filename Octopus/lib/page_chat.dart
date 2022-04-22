import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // TODO: implement initState

    Client.instance.addHandler("chat.text", (err, data) {
      Message msg = Message.fromJson(data);
      Data.data.addMessage(msg);
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
