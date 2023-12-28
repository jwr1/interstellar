import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/screens/posts/posts_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({
    super.key,
  });

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
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
          const TabBarView(
            children: [
              PostsListView(
                contentSource: ContentPostsSub(),
              ),
              PostsListView(
                contentSource: ContentPostsMod(),
              ),
              PostsListView(
                contentSource: ContentPostsFav(),
              ),
              PostsListView(
                contentSource: ContentPostsAll(),
              ),
            ],
          ),
          otherwise: const PostsListView(
            contentSource: ContentPostsAll(),
          ),
        ),
      ),
    );
  }
}
