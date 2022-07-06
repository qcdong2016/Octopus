import 'dart:io';

import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/page_chat.dart';
import 'package:system_tray/system_tray.dart';

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
    initSystemTray();

    super.initState();
  }

  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  final Menu _menuMain = Menu();

  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

    _menuMain.buildFrom([
      MenuItemLable(
          label: 'Show',
          onClicked: (menuItem) {
            _appWindow.show();
          }),
      MenuItemLable(
          label: 'Hide',
          onClicked: (menuItem) {
            _appWindow.hide();
          }),
      MenuItemLable(
        label: 'Exit',
        onClicked: (menuItem) {
          exit(0);
        },
      ),
    ]);

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(
      title: "",
      iconPath: path,
    );

    await _systemTray.setContextMenu(_menuMain);

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _appWindow.show();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

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
