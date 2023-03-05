import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';

import 'main.dart';

class NativeNotifyImpl {
  Future<void> show(String title, String body) async {}
  Future<void> init() async {}
}

class NativeNotifyMacos implements NativeNotifyImpl {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  Future<void> show(String title, String body) async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    if (result != null && result) {
      const NotificationDetails detail = NotificationDetails();
      await flutterLocalNotificationsPlugin.show(
          Random().nextInt(1000), title, body, detail);
    }
  }

  @override
  Future<void> init() async {
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        const InitializationSettings(
      macOS: initializationSettingsMacOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectedNotificationPayload = payload;
      // selectNotificationSubject.add(payload);
    });
  }
}

class NativeNotifyWindows implements NativeNotifyImpl {
  @override
  Future<void> init() async {
    // Add in main method.
    await localNotifier.setup(
      appName: 'Octopus',
      // The parameter shortcutPolicy only works on Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  LocalNotification? last;
  @override
  Future<void> show(String title, String body) async {
    last?.destroy();
    last = LocalNotification(
      title: title,
      body: body,
    );
    last?.show();
  }
}

class NativeNotify {
  static NativeNotifyImpl impl = NativeNotifyImpl();
  static Future<void> show(String title, String body) async {
    impl.show(title, body);
  }

  static Future<void> init() async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      impl = NativeNotifyMacos();
    } else {
      impl = NativeNotifyWindows();
    }

    impl.init();
  }
}
