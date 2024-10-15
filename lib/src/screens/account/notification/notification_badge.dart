import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

import 'notification_count_controller.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  @override
  Widget build(BuildContext context) {
    final count = context.watch<NotificationCountController>().value;

    return Wrapper(
      shouldWrap: count != 0,
      parentBuilder: (child) => badges.Badge(
        badgeContent: Text(count.toString()),
        child: child,
      ),
      child: widget.child,
    );
  }
}
