import 'package:flutter/material.dart';
import 'package:octopus/page_chat.dart';

import 'chat_input.dart';
import 'data.dart';
import 'friend_list.dart';
import 'message_list.dart';
import 'page_login.dart';

void main() {
  Data.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Octopus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        "/chat": ((context) => ChatPage()),
      },
    );
  }
}
