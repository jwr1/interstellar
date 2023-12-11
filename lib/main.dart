import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';

void main() async {
  final settingsController = SettingsController();

  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
}
