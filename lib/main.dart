import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/variables.dart';
import 'package:media_kit/media_kit.dart';

import 'src/app.dart';
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

  // Load user settings
  final settingsController = SettingsController();
  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
}
