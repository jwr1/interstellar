import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:interstellar/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/controller/server.dart';
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

String timeOnlyFormat(DateTime input) {
  return DateFormat.jms().format(input);
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
  ServerSoftware? matchesSoftware,
  T? otherwise,
}) =>
    context.read<AppController>().isLoggedIn &&
            (matchesUsername == null ||
                context
                        .read<AppController>()
                        .selectedAccount
                        .split('@')
                        .first ==
                    matchesUsername) &&
            (matchesSoftware == null ||
                context.read<AppController>().serverSoftware == matchesSoftware)
        ? value
        : otherwise;

String getNameHost(BuildContext context, String username) {
  final split = username.split('@');

  return split.length > 1
      ? split[1]
      : context.read<AppController>().instanceHost;
}

// Converts names in the format of:
// localpart -> localpart@hostname
// localpart@hostname -> localpart@hostname
String normalizeName(String name, String host) =>
    name.contains('@') ? name : '$name@$host';

// Converts names in the format of:
// localpart@hostname -> localpart
// localpart@hostname -> localpart@hostname
String denormalizeName(String name, String host) {
  final nameSplit = name.split('@');
  return nameSplit.last == host ? nameSplit.first : name;
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

AppLocalizations l(BuildContext context) => AppLocalizations.of(context)!;

List<T> reverseList<T>(List<T> list, bool enabled) {
  if (enabled) {
    return list.reversed.toList();
  }

  return list;
}

const chipDropdownPadding = EdgeInsets.only(
  left: 4,
  top: 6,
  right: 0,
  bottom: 6,
);

ScrollPhysics? appTabViewPhysics(BuildContext context) =>
    context.watch<AppController>().profile.disableTabSwiping
        ? const NeverScrollableScrollPhysics()
        : null;

class DefaultTabControllerListener extends StatefulWidget {
  const DefaultTabControllerListener(
      {super.key, this.onTabSelected, required this.child});

  final void Function(int index)? onTabSelected;
  final Widget child;

  @override
  State<DefaultTabControllerListener> createState() =>
      _DefaultTabControllerListenerState();
}

class _DefaultTabControllerListenerState
    extends State<DefaultTabControllerListener> {
  late final void Function()? _listener;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabController = DefaultTabController.of(context);
      _listener = () {
        if (tabController.indexIsChanging) {
          return;
        }

        final onTabSelected = widget.onTabSelected;
        if (onTabSelected != null) {
          onTabSelected(tabController.index);
        }
      };
      tabController.addListener(_listener!);
    });
  }

  @override
  void didChangeDependencies() {
    _tabController = DefaultTabController.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_listener != null && _tabController != null) {
      _tabController!.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Takes String as input, hashes it with MD5, and outputs a base64 String.
String strToMd5Base64(String input) {
  final inputBytes = utf8.encode(input);

  final hashBytes = md5.convert(inputBytes).bytes;
  final hashBase64 = base64.encode(hashBytes);

  return hashBase64;
}
