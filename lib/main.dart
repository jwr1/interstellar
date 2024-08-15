import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/variables.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/init_push_notifications.dart';
import 'src/screens/settings/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Show snackbar on error
  FlutterError.onError = (details) {
    FlutterError.presentError(details);

    // Don't show error for rendering issues
    if (details.library == 'rendering library') return;
    // Don't show error for image loading issues
    if (details.library == 'image resource service') return;

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(details.summary.toString())),
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
    return false;
  };

  final settingsController = SettingsController();
  await settingsController.loadSettings();

  if (Platform.isAndroid) {
    await initPushNotifications(settingsController);
  }

  runApp(ChangeNotifierProvider.value(
    value: settingsController,
    child: const App(),
  ));
}
