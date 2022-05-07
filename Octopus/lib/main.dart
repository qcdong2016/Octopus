import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/page_chat.dart';

import 'page_login.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // initSystemTray();

    super.initState();
  }

  // final SystemTray _systemTray = SystemTray();
  // final AppWindow _appWindow = AppWindow();

  // Future<void> initSystemTray() async {
  //   String path =
  //       Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

  //   final menu = [
  //     MenuItem(label: 'Show', onClicked: _appWindow.show),
  //     MenuItem(label: 'Hide', onClicked: _appWindow.hide),
  //     MenuItem(
  //       label: 'Exit',
  //       onClicked: () {
  //         exit(0);
  //       },
  //     ),
  //   ];

  //   // We first init the systray menu and then add the menu entries
  //   await _systemTray.initSystemTray(
  //     title: "",
  //     iconPath: path,
  //   );

  //   await _systemTray.setContextMenu(menu);

  //   // handle system tray event
  //   _systemTray.registerSystemTrayEventHandler((eventName) {
  //     debugPrint("eventName: $eventName");

  //     if (eventName == "leftMouseDown") {
  //     } else if (eventName == "leftMouseUp") {
  //       _appWindow.show();
  //     } else if (eventName == "rightMouseDown") {
  //     } else if (eventName == "rightMouseUp") {
  //       _systemTray.popUpContextMenu();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Octopus',
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(child: child);
      },
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
