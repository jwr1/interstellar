import 'dart:io';

import 'package:flutter/material.dart';

final isWebViewSupported = Platform.isAndroid || Platform.isIOS;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
