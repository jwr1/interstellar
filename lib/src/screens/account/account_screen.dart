import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/screens/account/notification/notification_badge.dart';
import 'package:interstellar/src/screens/account/notification/notification_screen.dart';
import 'package:interstellar/src/screens/account/self_feed.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'messages/messages_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return whenLoggedIn(
          context,
          context.read<AppController>().serverSoftware == ServerSoftware.lemmy
              ? const SelfFeed()
              : DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title:
                          Text(context.watch<AppController>().selectedAccount),
                      bottom: TabBar(tabs: [
                        Tab(
                          text: l(context).notifications,
                          icon: const NotificationBadge(
                              child: Icon(Symbols.notifications_rounded)),
                        ),
                        Tab(
                          text: l(context).messages,
                          icon: const Icon(Symbols.message_rounded),
                        ),
                        Tab(
                          text: l(context).profile_overview,
                          icon: const Icon(Symbols.person_rounded),
                        ),
                      ]),
                    ),
                    body: const TabBarView(children: [
                      NotificationsScreen(),
                      MessagesScreen(),
                      SelfFeed(),
                    ]),
                  ),
                ),
        ) ??
        Center(
          child: Text(l(context).notLoggedIn),
        );
  }
}
