import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  final int userId;
  final api_users.DetailedUser? data;

  const UserScreen(this.userId, {super.key, this.data});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  api_users.DetailedUser? _data;

  @override
  void initState() {
    super.initState();

    _data = widget.data;

    if (_data == null) {
      api_users
          .fetchUser(
              context.read<SettingsController>().instanceHost, widget.userId)
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_data?.username ?? '')),
      body: EntriesListView(
        contentSource: ContentUser(widget.userId),
        details: _data != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_data!.avatar?.storageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Image.network(
                              _data!.avatar!.storageUrl,
                              width: 64,
                              height: 64,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _data!.username,
                            style: Theme.of(context).textTheme.titleLarge,
                            softWrap: true,
                          ),
                        ),
                        OutlinedButton(
                            onPressed: () {},
                            child: Row(
                              children: [
                                const Icon(Icons.group),
                                Text(' ${intFormat(_data!.followersCount)}'),
                              ],
                            ))
                      ],
                    ),
                    if (_data!.about != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Markdown(_data!.about!),
                      )
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
