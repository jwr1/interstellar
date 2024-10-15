import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:webpush_encryption/webpush_encryption.dart';

Future<void> initPushNotifications(AppController appController) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@drawable/ic_launcher_monochrome'),
  ));

  final random = Random();

  await UnifiedPush.initialize(
    onNewEndpoint: (String endpoint, String instance) async {
      await appController.api.notifications.pushRegister(
        endpoint: endpoint,
        serverKey: appController.webPushKeys.auth,
        contentPublicKey: appController.webPushKeys.p256dh,
      );
    },
    onRegistrationFailed: (String instance) {
      appController.removePushRegistrationStatus(instance);
    },
    onUnregistered: (String instance) {
      appController.removePushRegistrationStatus(instance);
    },
    onMessage: (Uint8List message, String instance) async {
      final data = jsonDecode(utf8
          .decode(await WebPush.decrypt(appController.webPushKeys, message)));

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
