import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
import 'package:interstellar/src/screens/profile/message_thread_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/image_selector.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

import 'package:interstellar/src/models/post.dart';

enum UserFeedType { thread, microblog, comment, follower, following }

class UserScreen extends StatefulWidget {
  final int userId;
  final DetailedUserModel? initData;
  final void Function(DetailedUserModel)? onUpdate;

  const UserScreen(this.userId, {super.key, this.initData, this.onUpdate});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  DetailedUserModel? _data;
  TextEditingController? _messageController;
  TextEditingController? _aboutTextController;
  XFile? _avatarFile;
  XFile? _coverFile;

  @override
  void initState() {
    super.initState();

    _data = widget.initData;

    if (_data == null) {
      context
          .read<SettingsController>()
          .api
          .users
          .get(
            widget.userId,
          )
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_data?.name ?? ''),
        ),
        body: DefaultTabController(
          length: 5,
          child: NestedScrollView(
            headerSliverBuilder: (context, innBoxIsScolled) => [
              SliverToBoxAdapter(
                child: _data != null
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height / 3,
                            ),
                            height: _data!.cover == null ? 100 : null,
                            child: _data!.cover != null
                              ? Image.network(
                                _data!.cover!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                              : null,
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Avatar(
                                _data!.avatar,
                                radius: 32,
                                borderRadius: 4,
                              ),
                            )
                          ),
                          if (whenLoggedIn(context, true,
                              matchesUsername: _data!.name) !=
                              null)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: _aboutTextController == null
                                  ? TextButton(
                                  onPressed: () => setState(() {
                                    _aboutTextController =
                                        TextEditingController(
                                            text: _data!.about);
                                  }),
                                  child: const Text("Edit"))
                                  : Row(
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          var user = await context
                                              .read<SettingsController>()
                                              .api
                                              .users
                                              .updateProfile(
                                              _aboutTextController!.text);
                                          if (!mounted) return;
                                          if (_avatarFile != null) {
                                            user = await context
                                                .read<SettingsController>()
                                                .api
                                                .users
                                                .updateAvatar(_avatarFile!);
                                          }
                                          if (!mounted) return;
                                          if (_coverFile != null) {
                                            user = await context
                                                .read<SettingsController>()
                                                .api
                                                .users
                                                .updateCover(_coverFile!);
                                          }

                                          setState(() {
                                            _data = user;
                                            _aboutTextController!.dispose();
                                            _aboutTextController = null;
                                            _coverFile = null;
                                            _avatarFile = null;
                                          });
                                        },
                                        child: const Text("Save")),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _aboutTextController!.dispose();
                                            _aboutTextController = null;
                                          });
                                        },
                                        child: const Text("Cancel")),
                                    ],
                                ),
                              )
                            )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _data!.name.contains('@')
                                          ? _data!.name.split('@')[1]
                                          : _data!.name,
                                      style: Theme.of(context).textTheme.titleLarge,
                                      softWrap: true,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text: _data!.name.contains('@')
                                                ? _data!.name
                                                : '@${_data!.name}@${context.read<SettingsController>().instanceHost}'),
                                        );

                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Copied')));
                                      },
                                      child: Text(
                                        _data!.name.contains('@')
                                            ? _data!.name
                                            : '@${_data!.name}@${context.read<SettingsController>().instanceHost}',
                                        softWrap: true,
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStatePropertyAll(
                                          _data!.isFollowedByUser == true
                                              ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              : null),
                                      ),
                                      onPressed: whenLoggedIn(context, () async {
                                        var newValue = await context
                                            .read<SettingsController>()
                                            .api
                                            .users
                                            .putFollow(
                                            _data!.id, !_data!.isFollowedByUser!);
                                        setState(() {
                                          _data = newValue;
                                        });
                                        if (widget.onUpdate != null) {
                                          widget.onUpdate!(newValue);
                                        }
                                      }),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.group),
                                          Text(
                                              ' ${intFormat(_data!.followersCount)}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (whenLoggedIn(context, true) == true)
                                  IconButton(
                                    onPressed: () async {
                                      final newValue = await context
                                          .read<SettingsController>()
                                          .api
                                          .users
                                          .putBlock(
                                        _data!.id,
                                        !_data!.isBlockedByUser!,
                                      );

                                      setState(() {
                                        _data = newValue;
                                      });
                                      if (widget.onUpdate != null) {
                                        widget.onUpdate!(newValue);
                                      }
                                    },
                                    icon: const Icon(Icons.block),
                                    style: ButtonStyle(
                                      foregroundColor: MaterialStatePropertyAll(
                                          _data!.isBlockedByUser == true
                                              ? Theme.of(context).colorScheme.error
                                              : Theme.of(context).disabledColor),
                                    ),
                                  ),
                                if (!_data!.name.contains('@'))
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _messageController = TextEditingController();
                                      });
                                    },
                                    icon: const Icon(Icons.mail),
                                    tooltip: 'Send message',
                                  )
                              ],
                            ),
                            if (_messageController != null)
                              Column(children: [
                                TextEditor(
                                  _messageController!,
                                  isMarkdown: true,
                                  label: 'Message',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () async {
                                        setState(() {
                                          _messageController = null;
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        final newThread = await context
                                            .read<SettingsController>()
                                            .api
                                            .messages
                                            .create(
                                          _data!.id,
                                          _messageController!.text,
                                        );

                                        setState(() {
                                          _messageController = null;

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MessageThreadScreen(
                                                    initData: newThread,
                                                  ),
                                            ),
                                          );
                                        });
                                      },
                                      child: const Text('Send'),
                                    )
                                  ],
                                )
                              ]),
                            if (_data!.about != null || _aboutTextController != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _aboutTextController == null
                                  ? Markdown(
                                    _data!.about!,
                                    getNameHost(context, _data!.name),
                                  )
                                  : TextEditor(
                                    _aboutTextController!,
                                    label: "About",
                                    isMarkdown: true,
                                  )
                              ),
                            if (_aboutTextController != null)
                              Row(
                                children: [
                                  const Text("Select Avatar"),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ImageSelector(
                                      _avatarFile,
                                      (file) => setState(() {
                                        _avatarFile = file;
                                      })),
                                  )
                                ],
                              ),
                            if (_aboutTextController != null)
                              Row(
                                children: [
                                  const Text("Select Cover"),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ImageSelector(
                                      _coverFile,
                                      (file) => setState(() {
                                        _coverFile = file;
                                      }),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ) : null
                ),
              const SliverAppBar(
                automaticallyImplyLeading: false,
                title: TabBar(
                  tabs: [
                    Tab(
                      text: 'Threads',
                      icon: Icon(Icons.feed)
                    ),
                    Tab(
                      text: 'Microblogs',
                      icon: Icon(Icons.chat)
                    ),
                    Tab(
                      text: 'Comments',
                      icon: Icon(Icons.comment),
                    ),
                    Tab(
                      text: 'Followers',
                      icon: Icon(Icons.follow_the_signs),
                    ),
                    Tab(
                      text: 'Following',
                      icon: Icon(Icons.follow_the_signs),
                    )
                  ],
                ),
                pinned: true,
              )
            ],
            body: TabBarView(
              children: [
                UserScreenBody(
                  mode: UserFeedType.thread,
                  data: _data,
                ),
                UserScreenBody(
                    mode: UserFeedType.microblog,
                    data: _data
                ),
                UserScreenBody(
                    mode: UserFeedType.comment,
                    data: _data
                ),
                UserScreenBody(
                    mode: UserFeedType.follower,
                    data: _data
                ),
                UserScreenBody(
                    mode: UserFeedType.following,
                    data: _data
                ),
              ]
            ),
        ),
      )
    );
  }
}

class UserScreenBody extends StatefulWidget {
  final UserFeedType mode;
  final DetailedUserModel? data;

  const UserScreenBody({
    super.key,
    required this.mode,
    this.data
  });

  @override
  State<UserScreenBody> createState() => _UserScreenBodyState();
}

class _UserScreenBodyState extends State<UserScreenBody> {
  final PagingController<String, dynamic> _pagingController =
      PagingController(firstPageKey: '1');

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pagingController.refresh();
  }

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage = await (switch (widget.mode) {
        UserFeedType.thread =>
            context.read<SettingsController>().api.entries.list(
          FeedSource.user,
          sourceId: widget.data!.id,
          page: pageKey,
          sort: FeedSort.newest,
          usePreferredLangs: whenLoggedIn(context,
              context.read<SettingsController>().useAccountLangFilter),
          langs: context.read<SettingsController>().langFilter.toList(),
        ),
        UserFeedType.microblog =>
            context.read<SettingsController>().api.posts.list(
              FeedSource.user,
              sourceId: widget.data!.id,
          page: pageKey,
          sort: FeedSort.newest,
          usePreferredLangs: whenLoggedIn(context,
              context.read<SettingsController>().useAccountLangFilter),
          langs: context.read<SettingsController>().langFilter.toList(),
        ),
        UserFeedType.comment =>
            context.read<SettingsController>().api.posts.list(
              FeedSource.user,
              sourceId: widget.data!.id,
              page: pageKey,
              sort: FeedSort.newest,
              usePreferredLangs: whenLoggedIn(context,
                  context.read<SettingsController>().useAccountLangFilter),
              langs: context.read<SettingsController>().langFilter.toList(),
            ),
        UserFeedType.follower =>
            context.read<SettingsController>().api.posts.list(
              FeedSource.user,
              sourceId: widget.data!.id,
              page: pageKey,
              sort: FeedSort.newest,
              usePreferredLangs: whenLoggedIn(context,
                  context.read<SettingsController>().useAccountLangFilter),
              langs: context.read<SettingsController>().langFilter.toList(),
            ),
        UserFeedType.following =>
            context.read<SettingsController>().api.posts.list(
              FeedSource.user,
              sourceId: widget.data!.id,
              page: pageKey,
              sort: FeedSort.newest,
              usePreferredLangs: whenLoggedIn(context,
                  context.read<SettingsController>().useAccountLangFilter),
              langs: context.read<SettingsController>().langFilter.toList(),
            ),
      });

      if (!mounted) return;

      List<dynamic> newItems = [];
      final currentItemIds =
          _pagingController.itemList?.map((post) => post.id) ?? [];
      newItems = newPage.items
          .where((post) => !currentItemIds.contains(post.id))
          .toList();

      _pagingController.appendPage(newItems, newPage.nextPage);

    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
          () => _pagingController.refresh()
      ),
      child: CustomScrollView(
        slivers: [
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              itemBuilder: (context, item, index) {
                return switch (widget.mode) {
                  UserFeedType.thread =>
                      PostItem(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        isPreview: item.type == PostType.thread,
                      ),
                  UserFeedType.microblog =>
                      PostItem(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        isPreview: item.type == PostType.thread,
                      ),
                  UserFeedType.comment => Text("comment"),
                  UserFeedType.follower => Text("follower"),
                  UserFeedType.following => Text("Following")
                };
              }
            )
          )
        ],
      ),
    );
  }

}