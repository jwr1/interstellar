import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/profile/messages_screen.dart';
import 'package:interstellar/src/screens/profile/notification/notification_badge.dart';
import 'package:interstellar/src/screens/profile/notification/notification_screen.dart';
import 'package:interstellar/src/screens/profile/self_feed.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return whenLoggedIn(
          context,
          context.read<SettingsController>().serverSoftware ==
                  ServerSoftware.lemmy
              ? const SelfFeed()
              : DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(
                          context.watch<SettingsController>().selectedAccount),
                      bottom: const TabBar(tabs: [
                        Tab(
                          text: 'Notifications',
                          icon: NotificationBadge(
                              child: Icon(Icons.notifications)),
                        ),
                        Tab(
                          text: 'Overview',
                          icon: Icon(Icons.person),
                        ),
                        Tab(
                          text: 'Messages',
                          icon: Icon(Icons.message),
                        ),
                      ]),
                    ),
                    body: const TabBarView(children: [
                      NotificationsScreen(),
                      SelfFeed(),
                      MessagesScreen(),
                    ]),
                  ),
                ),
        ) ??
        const Center(
          child: Text('Not logged in'),
        );
  }
}
