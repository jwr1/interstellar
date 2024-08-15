import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:webpush_encryption/webpush_encryption.dart';

import 'screens/settings/settings_controller.dart';

Future<void> initPushNotifications(
    SettingsController settingsController) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@drawable/ic_launcher_monochrome'),
  ));

  final random = Random();

  await UnifiedPush.initialize(
    onNewEndpoint: (String endpoint, String instance) async {
      print('register start');
      print(endpoint);
      await settingsController.api.notifications.pushRegister(
        endpoint: endpoint,
        serverKey: settingsController.webPushKeys.auth,
        contentPublicKey: settingsController.webPushKeys.p256dh,
      );
      print('register finish');
    },
    // onRegistrationFailed: (String instance) {},
    // onUnregistered: (String instance) {},
    onMessage: (Uint8List message, String instance) async {
      final data = jsonDecode(utf8.decode(
          await WebPush.decrypt(settingsController.webPushKeys, message)));

      print(data);

      await flutterLocalNotificationsPlugin.show(
        random.nextInt(2 ^ 31 - 1),
        data['title'],
        data['message'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            data['category'] as String,
            data['category'] as String,
          ),
        ),
        // payload: data['actionUrl'],
      );
    },
  );
}
