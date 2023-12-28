import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/posts/posts_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

enum FeedMode { entries, posts }
enum FeedSource { all, sub, fav, mod }

class _FeedScreenState extends State<FeedScreen> {
  FeedSource _contentSource = FeedSource.all;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.read<SettingsController>().selectedAccount +
              (context.read<SettingsController>().isLoggedIn
                  ? ''
                  : ' (Anonymous)')),
          actions: whenLoggedIn(context, [
            MenuBar(
                children: [
                    SubmenuButton(
                        menuChildren: [
                          MenuItemButton(
                            child: const Text("All"),
                            onPressed: () {
                              setState(() {
                                _contentSource = FeedSource.all;
                              });
                            },
                          ),
                          MenuItemButton(
                            child: const Text("Sub"),
                            onPressed: () {
                              setState(() {
                                _contentSource = FeedSource.sub;
                              });
                            },
                          ),
                          MenuItemButton(
                            child: const Text("Fav"),
                            onPressed: () {
                              setState(() {
                                _contentSource = FeedSource.fav;
                              });
                            },
                          ),
                          MenuItemButton(
                            child: const Text("Mod"),
                            onPressed: () {
                              setState(() {
                                _contentSource = FeedSource.mod;
                              });
                            },
                          ),
                        ],
                        child: switch(_contentSource) {
                          FeedSource.all => const Text("All"),
                          FeedSource.sub => const Text("Sub"),
                          FeedSource.fav => const Text("Fav"),
                          FeedSource.mod => const Text("Mod"),
                        }
                    )
            ])
          ]),
          bottom:
            const TabBar(tabs: [
              Tab(
                text: 'Threads',
                icon: Icon(Icons.group),
              ),
              Tab(
                text: 'Microblogs',
                icon: Icon(Icons.lock),
              ),
            ]),
        ),
        body:
          TabBarView(
              children: [
                EntriesListView(contentSource: (switch (_contentSource) {
                  FeedSource.all => const ContentAll(),
                  FeedSource.sub => const ContentSub(),
                  FeedSource.mod => const ContentMod(),
                  FeedSource.fav => const ContentFav()
                })),
                PostsListView(contentSource: (switch (_contentSource) {
                  FeedSource.all => const ContentPostsAll(),
                  FeedSource.sub => const ContentPostsSub(),
                  FeedSource.mod => const ContentPostsMod(),
                  FeedSource.fav => const ContentPostsFav()
                }))
              ]
          ),
      ),
    );
  }
}
