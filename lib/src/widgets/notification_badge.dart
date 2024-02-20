import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _count = 0;

  @override
  void initState() {
    super.initState();

    context
        .read<SettingsController>()
        .api
        .notifications
        .getCount()
        .then((value) => setState(() {
              _count = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      shouldWrap: _count != 0,
      parentBuilder: (child) => badges.Badge(
        badgeContent: Text('$_count'),
        child: child,
      ),
      child: widget.child,
    );
  }
}
