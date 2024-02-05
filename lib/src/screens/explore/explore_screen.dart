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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'Explore ${context.watch<SettingsController>().instanceHost}'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()
                    )
                  );
                },
                icon: const Icon(Icons.search)
            )
          ],
          bottom: const TabBar(tabs: [
            Tab(
              text: 'Magazines',
              icon: Icon(Icons.article),
            ),
            // Tab(
            //   text: 'Collections',
            //   icon: Icon(Icons.newspaper),
            // ),
            Tab(
              text: 'People',
              icon: Icon(Icons.account_circle),
            ),
            Tab(
              text: 'Domains',
              icon: Icon(Icons.public),
            ),
          ]),
        ),
        body: const TabBarView(children: [
          MagazinesScreen(),
          // Placeholder(),
          UsersScreen(),
          DomainsScreen()
        ]),
      ),
    );
  }
}
