import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/explore/domains_screen.dart';
import 'package:interstellar/src/screens/explore/magazines_screen.dart';
import 'package:interstellar/src/screens/explore/search_screen.dart';
import 'package:interstellar/src/screens/explore/users_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: context.watch<SettingsController>().serverSoftware ==
              ServerSoftware.lemmy
          ? 2
          : 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'Explore ${context.watch<SettingsController>().instanceHost}'),
          bottom: TabBar(tabs: [
            const Tab(
              text: 'Magazines',
              icon: Icon(Icons.article),
            ),
            if (context.watch<SettingsController>().serverSoftware !=
                ServerSoftware.lemmy)
              const Tab(
                text: 'People',
                icon: Icon(Icons.account_circle),
              ),
            if (context.watch<SettingsController>().serverSoftware !=
                ServerSoftware.lemmy)
              const Tab(
                text: 'Domains',
                icon: Icon(Icons.public),
              ),
            const Tab(
              text: 'Search',
              icon: Icon(Icons.search),
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            const MagazinesScreen(),
            if (context.watch<SettingsController>().serverSoftware !=
                ServerSoftware.lemmy)
              const UsersScreen(),
            if (context.watch<SettingsController>().serverSoftware !=
                ServerSoftware.lemmy)
              const DomainsScreen(),
            const SearchScreen(),
          ],
        ),
      ),
    );
  }
}
