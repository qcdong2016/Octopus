import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/data.dart';
import 'package:octopus/native_notify.dart';
import 'package:octopus/page_chat.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import 'page_login.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    // size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  showFocus() async {
    await windowManager.show();
    await windowManager.focus();
  }

  windowManager.waitUntilReadyToShow(windowOptions, showFocus);

  NativeNotify.init();

  Data.notifyEvent.connect(showFocus);

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
  final Menu _menuMain = Menu();

  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

    _menuMain.buildFrom([
      MenuItemLabel(
          label: 'Show',
          onClicked: (menuItem) {
            windowManager.show();
          }),
      MenuItemLabel(
          label: 'Hide',
          onClicked: (menuItem) {
            windowManager.hide();
          }),
      MenuItemLabel(
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
        windowManager.show();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme;

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      theme = ThemeData(primarySwatch: Colors.blue);
    } else {
      theme = ThemeData(
        fontFamily: "Microsoft YaHei",
        primarySwatch: Colors.blue,
      );
    }

    return MaterialApp(
      title: 'Octopus',
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(child: child);
      },
      theme: theme,
      home: const LoginPage(),
      routes: {
        "/chat": ((context) => const ChatPage()),
      },
    );
  }
}
