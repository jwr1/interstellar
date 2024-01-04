import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

var intF = NumberFormat.compact();
String intFormat(int input) {
  return intF.format(input);
}

String timeDiffFormat(DateTime input) {
  final difference = DateTime.now().difference(input);

  if (difference.inDays > 0) {
    var years = (difference.inDays / 365).truncate();
    if (years >= 1) {
      return "${years}Y";
    }

    var months = (difference.inDays / 30).truncate();
    if (months >= 1) {
      return "${months}M";
    }

    var weeks = (difference.inDays / 7).truncate();
    if (weeks >= 1) {
      return "${weeks}w";
    }

    var days = difference.inDays;
    return "${days}d";
  }

  var hours = difference.inHours;
  if (hours > 0) {
    return "${hours}h";
  }

  var minutes = difference.inMinutes;
  if (minutes > 0) {
    return "${minutes}m";
  }

  var seconds = difference.inSeconds;
  return "${seconds}s";
}

void httpErrorHandler(http.Response response, {String? message}) {
  if (response.statusCode >= 400) {
    String? errorDetails;

    try {
      errorDetails = jsonDecode(response.body)['detail'];
    } catch (e) {
      // No error details provided
    }

    throw Exception(
        '${message != null ? '$message: ' : ''}${response.statusCode}${errorDetails != null ? ' $errorDetails' : ''}');
  }
}

Map<String, dynamic> removeNulls(Map<String, dynamic> map) {
  map.forEach((key, value) {
    if (value == null) {
      map.remove(key);
    }
  });
  return map;
}

T? whenLoggedIn<T>(
  BuildContext context,
  T? value, {
  String? matchesUsername,
  T? otherwise,
}) =>
    context.read<SettingsController>().isLoggedIn &&
            (matchesUsername == null ||
                context
                        .read<SettingsController>()
                        .selectedAccount
                        .split("@")
                        .first ==
                    matchesUsername)
        ? value
        : otherwise;
