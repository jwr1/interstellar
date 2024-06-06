import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String intFormat(int input) {
  return NumberFormat.compact().format(input);
}

String dateOnlyFormat(DateTime input) {
  return DateFormat.yMMMMd().format(input);
}

String dateTimeFormat(DateTime input) {
  return DateFormat().format(input);
}

String dateDiffFormat(DateTime input) {
  final difference = DateTime.now().difference(input);

  if (difference.inDays > 0) {
    var years = (difference.inDays / 365).truncate();
    if (years >= 1) {
      return '${years}Y';
    }

    var months = (difference.inDays / 30).truncate();
    if (months >= 1) {
      return '${months}M';
    }

    var weeks = (difference.inDays / 7).truncate();
    if (weeks >= 1) {
      return '${weeks}w';
    }

    var days = difference.inDays;
    return '${days}d';
  }

  var hours = difference.inHours;
  if (hours > 0) {
    return '${hours}h';
  }

  var minutes = difference.inMinutes;
  if (minutes > 0) {
    return '${minutes}m';
  }

  var seconds = difference.inSeconds;
  return '${seconds}s';
}

bool isSameDayOfYear(DateTime input) {
  final now = DateTime.now();

  return input.month == now.month && input.day == now.day;
}

void httpErrorHandler(http.Response response, {String? message}) {
  if (response.statusCode >= 400) {
    String? errorDetails;

    try {
      errorDetails = jsonDecode(response.body)['detail'];
    } catch (e) {
      // No error details provided
      errorDetails = response.reasonPhrase;
    }

    throw Exception(
      '${message != null ? '$message: ' : ''}${response.statusCode} ${errorDetails ?? ''}',
    );
  }
}

Map<String, String> queryParams(Map<String, String?> map) {
  return Map<String, String>.from(
    Map.fromEntries(
      map.entries.where((e) => (e.value != null && e.value!.isNotEmpty)),
    ),
  );
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
                        .split('@')
                        .first ==
                    matchesUsername)
        ? value
        : otherwise;

String getNameHost(BuildContext context, String username) {
  final split = username.split('@');

  return split.length > 1
      ? split[1]
      : context.read<SettingsController>().instanceHost;
}

String? nullIfEmpty(String value) => value.isEmpty ? null : value;

T parseEnum<T extends Enum>(
  List<T> enumValues,
  T defaultValue,
  String? name,
) {
  if (name == null) return defaultValue;

  return enumValues.firstWhere(
    (v) => v.name == name,
    orElse: () => defaultValue,
  );
}

bool isValidUrl(String url) => Uri.tryParse(url)?.host.isNotEmpty ?? false;

String readableShortcut(SingleActivator shortcut) {
  var text = '';

  if (shortcut.control) text += 'Ctrl+';
  if (shortcut.alt) text += 'Alt+';
  if (shortcut.shift) text += 'Shift+';
  if (shortcut.meta) text += 'Meta+';
  text += switch (shortcut.trigger.keyLabel) {
    ' ' => 'Space',
    String key => key,
  };

  return text;
}
