import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/screens/settings/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load user settings
  final settingsController = SettingsController();
  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
}
