import 'package:flutter/material.dart';
import 'package:interstellar/src/api/domains.dart';
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/api/users.dart';
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/explore/domains_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/magazines_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/explore/users_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/settings_header.dart';
import 'package:interstellar/src/widgets/star_button.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  List<DetailedMagazineModel>? subbedMagazines;
  List<DetailedUserModel>? subbedUsers;
  List<DomainModel>? subbedDomains;

  @override
  void initState() {
    super.initState();

    if (context.read<SettingsController>().isLoggedIn) {
      context
          .read<SettingsController>()
          .api
          .magazines
          .list(filter: APIMagazinesFilter.subscribed)
          .then((value) => setState(() {
                if (value.items.isNotEmpty) {
                  subbedMagazines = value.items;
                }
              }));
      if (context.read<SettingsController>().serverSoftware !=
          ServerSoftware.lemmy) {
        context
            .read<SettingsController>()
            .api
            .users
            .list(filter: UsersFilter.followed)
            .then((value) => setState(() {
                  if (value.items.isNotEmpty) {
                    subbedUsers = value.items;
                  }
                }));
        context
            .read<SettingsController>()
            .api
            .domains
            .list(filter: MbinAPIDomainsFilter.subscribed)
            .then((value) => setState(() {
                  if (value.items.isNotEmpty) {
                    subbedDomains = value.items;
                  }
                }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SettingsHeader(l(context).stars),
            ),
            if (context.watch<SettingsController>().stars.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l(context).stars_empty,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ...(context.watch<SettingsController>().stars.toList()..sort()).map(
              (star) => ListTile(
                title: Text(star),
                onTap: () async {
                  String name = star.substring(1);
                  if (name.endsWith(
                      context.read<SettingsController>().instanceHost)) {
                    name = name.split('@').first;
                  }

                  switch (star[0]) {
                    case '@':
                      final user = await context
                          .read<SettingsController>()
                          .api
                          .users
                          .getByName(name);

                      if (!mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UserScreen(user.id, initData: user),
                        ),
                      );
                      break;

                    case '!':
                      final magazine = await context
                          .read<SettingsController>()
                          .api
                          .magazines
                          .getByName(name);

                      if (!mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MagazineScreen(magazine.id, initData: magazine),
                        ),
                      );
                      break;
                  }
                },
                trailing: StarButton(star),
              ),
            ),
            if (context.read<SettingsController>().isLoggedIn &&
                subbedMagazines == null &&
                subbedUsers == null &&
                subbedDomains == null)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            if (context.watch<SettingsController>().isLoggedIn &&
                (subbedMagazines != null ||
                    subbedUsers != null ||
                    subbedDomains != null)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SettingsHeader(l(context).subscriptions),
              ),
              if (subbedMagazines != null) ...[
                ...subbedMagazines!
                    .asMap()
                    .map(
                      (index, magazine) => MapEntry(
                        index,
                        ListTile(
                          title: Text(magazine.name),
                          leading: magazine.icon == null
                              ? null
                              : Avatar(magazine.icon, radius: 16),
                          trailing: StarButton(magazine.name.contains('@')
                              ? '!${magazine.name}'
                              : '!${magazine.name}@${context.watch<SettingsController>().instanceHost}'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MagazineScreen(
                                  magazine.id,
                                  initData: magazine,
                                  onUpdate: (newValue) {
                                    setState(() {
                                      subbedMagazines![index] = newValue;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .values,
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                              title: Text(l(context).subscriptions_magazine)),
                          body: const MagazinesScreen(onlySubbed: true),
                        ),
                      ),
                    ),
                    child: Text(l(context).subscriptions_magazine_all),
                  ),
                ),
              ],
            ],
            if (context.read<SettingsController>().serverSoftware !=
                    ServerSoftware.lemmy &&
                subbedUsers != null) ...[
              ...subbedUsers!
                  .asMap()
                  .map(
                    (index, user) => MapEntry(
                      index,
                      ListTile(
                        title: Text(user.name),
                        leading: user.avatar == null
                            ? null
                            : Avatar(user.avatar, radius: 16),
                        trailing: StarButton(user.name.contains('@')
                            ? '@${user.name}'
                            : '@${user.name}@${context.watch<SettingsController>().instanceHost}'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserScreen(
                                user.id,
                                initData: user,
                                onUpdate: (newValue) {
                                  setState(() {
                                    subbedUsers![index] = newValue;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .values,
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar:
                            AppBar(title: Text(l(context).subscriptions_user)),
                        body: const UsersScreen(onlySubbed: true),
                      ),
                    ),
                  ),
                  child: Text(l(context).subscriptions_user_all),
                ),
              ),
            ],
            if (context.read<SettingsController>().serverSoftware !=
                    ServerSoftware.lemmy &&
                subbedDomains != null) ...[
              ...subbedDomains!
                  .asMap()
                  .map(
                    (index, domain) => MapEntry(
                      index,
                      ListTile(
                        title: Text(domain.name),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DomainScreen(
                                domain.id,
                                initData: domain,
                                onUpdate: (newValue) {
                                  setState(() {
                                    subbedDomains![index] = domain;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .values,
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                            title: Text(l(context).subscriptions_domain)),
                        body: const DomainsScreen(onlySubbed: true),
                      ),
                    ),
                  ),
                  child: Text(l(context).subscriptions_domain_all),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
