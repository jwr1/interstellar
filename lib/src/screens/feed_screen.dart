import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/screens/create_screen.dart';
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/posts/posts_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

enum FeedMode { entries, posts }

class _FeedScreenState extends State<FeedScreen> {
  FeedMode _feedMode = FeedMode.entries;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.read<SettingsController>().selectedAccount +
              (context.read<SettingsController>().isLoggedIn
                  ? ''
                  : ' (Anonymous)')),
          actions: [
            SegmentedButton(
              segments: const [
                ButtonSegment(
                  value: FeedMode.entries,
                  label: Text("Threads"),
                ),
                ButtonSegment(
                  value: FeedMode.posts,
                  label: Text("Posts"),
                ),
              ],
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
              ),
              selected: <FeedMode>{_feedMode},
              onSelectionChanged: (Set<FeedMode> newSelection) {
                setState(() {
                  _feedMode = newSelection.first;
                });
              },
            ),
          ],
          bottom: whenLoggedIn(
            context,
            const TabBar(tabs: [
              Tab(
                text: 'Sub',
                icon: Icon(Icons.group),
              ),
              Tab(
                text: 'Mod',
                icon: Icon(Icons.lock),
              ),
              Tab(
                text: 'Fav',
                icon: Icon(Icons.favorite),
              ),
              Tab(
                text: 'All',
                icon: Icon(Icons.newspaper),
              ),
            ]),
          ),
        ),
        body: whenLoggedIn(
          context,
          TabBarView(
            children: switch (_feedMode) {
              FeedMode.entries => ([
                  const EntriesListView(
                    contentSource: ContentSub(),
                  ),
                  const EntriesListView(
                    contentSource: ContentMod(),
                  ),
                  const EntriesListView(
                    contentSource: ContentFav(),
                  ),
                  const EntriesListView(
                    contentSource: ContentAll(),
                  ),
                ]),
              FeedMode.posts => ([
                  const PostsListView(
                    contentSource: ContentSub(),
                  ),
                  const PostsListView(
                    contentSource: ContentMod(),
                  ),
                  const PostsListView(
                    contentSource: ContentFav(),
                  ),
                  const PostsListView(
                    contentSource: ContentAll(),
                  ),
                ])
            },
          ),
          otherwise: switch (_feedMode) {
            FeedMode.entries => const EntriesListView(
                contentSource: ContentAll(),
              ),
            FeedMode.posts => const PostsListView(
                contentSource: ContentAll(),
              ),
          },
        ),
        floatingActionButton: whenLoggedIn(context, FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const CreateScreen()
              )
            );
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        )),
      ),
    );
  }
}
