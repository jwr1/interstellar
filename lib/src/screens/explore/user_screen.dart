import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/feed/post_comment.dart';
import 'package:interstellar/src/screens/feed/post_comment_screen.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
import 'package:interstellar/src/screens/feed/post_page.dart';
import 'package:interstellar/src/screens/profile/message_thread_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/image_selector.dart';
import 'package:interstellar/src/widgets/loading_template.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

enum UserFeedType { thread, microblog, comment, reply, follower, following }

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
  late FeedSort _sort;

  @override
  void initState() {
    super.initState();

    _data = widget.initData;
    _sort = context.read<SettingsController>().defaultExploreFeedSort;

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
    if (_data == null) {
      return const LoadingTemplate();
    }

    final user = _data!;
    final currentFeedSortOption = feedSortSelect.getOption(_sort);

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(user.name),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('•'),
                    ),
                    Icon(currentFeedSortOption.icon, size: 20),
                    const SizedBox(width: 2),
                    Text(currentFeedSortOption.title),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async {
                  final newSort =
                      await feedSortSelect.inquireSelection(context, _sort);

                  if (newSort != null && newSort != _sort) {
                    setState(() {
                      _sort = newSort;
                    });
                  }
                },
                icon: const Icon(Icons.sort),
              ),
            ),
          ],
        ),
        body: DefaultTabController(
          length: context.watch<SettingsController>().serverSoftware ==
                  ServerSoftware.lemmy
              ? 2
              : 6,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height / 3,
                        ),
                        height: user.cover == null ? 100 : null,
                        child: user.cover != null
                            ? Image.network(
                                user.cover!,
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
                            user.avatar,
                            radius: 32,
                            borderRadius: 4,
                          ),
                        ),
                      ),
                      if (whenLoggedIn(context, true,
                              matchesUsername: user.name) !=
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
                                                    text: user.about);
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
                                                      _aboutTextController!
                                                          .text);
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
                                                if (user != null) {
                                                  _data = user;
                                                }
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
                            ))
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
                                  user.name.contains('@')
                                      ? user.name.split('@')[1]
                                      : user.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  softWrap: true,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                          text: user.name.contains('@')
                                              ? user.name
                                              : '@${user.name}@${context.read<SettingsController>().instanceHost}'),
                                    );

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Copied')));
                                  },
                                  child: Text(
                                    user.name.contains('@')
                                        ? user.name
                                        : '@${user.name}@${context.read<SettingsController>().instanceHost}',
                                    softWrap: true,
                                  ),
                                )
                              ],
                            ),
                            const Spacer(),
                            if (user.followersCount != null)
                              SubscriptionButton(
                                subsCount: user.followersCount!,
                                isSubed: user.isFollowedByUser == true,
                                onPress: whenLoggedIn(context, () async {
                                  var newValue = await context
                                      .read<SettingsController>()
                                      .api
                                      .users
                                      .follow(user.id, !user.isFollowedByUser!);
                                  setState(() {
                                    _data = newValue;
                                  });
                                  if (widget.onUpdate != null) {
                                    widget.onUpdate!(newValue);
                                  }
                                }),
                              ),
                            if (whenLoggedIn(context, true) == true)
                              IconButton(
                                onPressed: () async {
                                  final newValue = await context
                                      .read<SettingsController>()
                                      .api
                                      .users
                                      .putBlock(
                                        user.id,
                                        !user.isBlockedByUser!,
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
                                      user.isBlockedByUser == true
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context).disabledColor),
                                ),
                              ),
                            if (!user.name.contains('@') &&
                                context
                                        .read<SettingsController>()
                                        .serverSoftware !=
                                    ServerSoftware.lemmy)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _messageController =
                                        TextEditingController();
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
                                          user.id,
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
                        if (user.about != null || _aboutTextController != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _aboutTextController == null
                                  ? Markdown(
                                      user.about!,
                                      getNameHost(context, user.name),
                                    )
                                  : TextEditor(
                                      _aboutTextController!,
                                      label: "About",
                                      isMarkdown: true,
                                    )),
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
              )),
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    const Tab(
                      text: 'Threads',
                      icon: Icon(Icons.feed),
                    ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      const Tab(
                        text: 'Microblogs',
                        icon: Icon(Icons.chat),
                      ),
                    const Tab(
                      text: 'Comments',
                      icon: Icon(Icons.comment),
                    ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      const Tab(
                        text: 'Replies',
                        icon: Icon(Icons.comment),
                      ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      const Tab(
                        text: 'Followers',
                        icon: Icon(Icons.people),
                      ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      const Tab(
                        text: 'Following',
                        icon: Icon(Icons.groups),
                      )
                  ],
                ),
                pinned: true,
              )
            ],
            body: TabBarView(children: [
              UserScreenBody(
                mode: UserFeedType.thread,
                sort: _sort,
                data: _data,
              ),
              if (context.watch<SettingsController>().serverSoftware !=
                  ServerSoftware.lemmy)
                UserScreenBody(
                  mode: UserFeedType.microblog,
                  sort: _sort,
                  data: _data,
                ),
              UserScreenBody(
                mode: UserFeedType.comment,
                sort: _sort,
                data: _data,
              ),
              if (context.watch<SettingsController>().serverSoftware !=
                  ServerSoftware.lemmy)
                UserScreenBody(
                  mode: UserFeedType.reply,
                  sort: _sort,
                  data: _data,
                ),
              if (context.watch<SettingsController>().serverSoftware !=
                  ServerSoftware.lemmy)
                UserScreenBody(
                  mode: UserFeedType.follower,
                  sort: _sort,
                  data: _data,
                ),
              if (context.watch<SettingsController>().serverSoftware !=
                  ServerSoftware.lemmy)
                UserScreenBody(
                  mode: UserFeedType.following,
                  sort: _sort,
                  data: _data,
                ),
            ]),
          ),
        ));
  }
}

class UserScreenBody extends StatefulWidget {
  final UserFeedType mode;
  final FeedSort sort;
  final DetailedUserModel? data;

  const UserScreenBody({
    super.key,
    required this.mode,
    required this.sort,
    this.data,
  });

  @override
  State<UserScreenBody> createState() => _UserScreenBodyState();
}

class _UserScreenBodyState extends State<UserScreenBody> {
  final PagingController<String, dynamic> _pagingController =
      PagingController(firstPageKey: '');

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
    const Map<FeedSort, CommentSort> feedToCommentSortMap = {
      FeedSort.active: CommentSort.active,
      FeedSort.commented: CommentSort.active,
      FeedSort.hot: CommentSort.hot,
      FeedSort.newest: CommentSort.newest,
      FeedSort.oldest: CommentSort.oldest,
      FeedSort.top: CommentSort.top,
    };

    try {
      final newPage = await (switch (widget.mode) {
        UserFeedType.thread =>
          context.read<SettingsController>().api.threads.list(
                FeedSource.user,
                sourceId: widget.data!.id,
                page: nullIfEmpty(pageKey),
                sort: widget.sort,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        UserFeedType.microblog =>
          context.read<SettingsController>().api.microblogs.list(
                FeedSource.user,
                sourceId: widget.data!.id,
                page: nullIfEmpty(pageKey),
                sort: widget.sort,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        UserFeedType.comment =>
          context.read<SettingsController>().api.comments.listFromUser(
                PostType.thread,
                widget.data!.id,
                page: nullIfEmpty(pageKey),
                sort: feedToCommentSortMap[widget.sort],
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        UserFeedType.reply =>
          context.read<SettingsController>().api.comments.listFromUser(
                PostType.microblog,
                widget.data!.id,
                page: nullIfEmpty(pageKey),
                sort: feedToCommentSortMap[widget.sort],
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        UserFeedType.follower =>
          context.read<SettingsController>().api.users.listFollowers(
                widget.data!.id,
                page: nullIfEmpty(pageKey),
              ),
        UserFeedType.following =>
          context.read<SettingsController>().api.users.listFollowing(
                widget.data!.id,
                page: nullIfEmpty(pageKey),
              ),
      });

      if (!mounted) return;

      final currentItemIds =
          _pagingController.itemList?.map((post) => post.id) ?? [];
      List<dynamic> newItems = (switch (newPage) {
        PostListModel newPage => newPage.items
            .where((element) => !currentItemIds.contains(element.id))
            .toList(),
        CommentListModel newPage => newPage.items
            .where((element) => !currentItemIds.contains(element.id))
            .toList(),
        DetailedUserListModel newPage => newPage.items
            .where((element) => !currentItemIds.contains(element.id))
            .toList(),
        Object _ => []
      });

      _pagingController.appendPage(
          newItems,
          (switch (newPage) {
            PostListModel newPage => newPage.nextPage,
            CommentListModel newPage => newPage.nextPage,
            DetailedUserListModel newPage => newPage.nextPage,
            Object _ => null
          }));
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _pagingController.refresh()),
      child: CustomScrollView(
        slivers: [
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
                itemBuilder: (context, item, index) {
              onClick() {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    switch (widget.mode) {
                      case UserFeedType.follower:
                      case UserFeedType.following:
                        return UserScreen(
                          item.id,
                          initData: item,
                          onUpdate: (newValue) {
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          },
                        );
                      case UserFeedType.thread:
                      case UserFeedType.microblog:
                        return PostPage(
                          initData: item,
                          onUpdate: (newValue) {
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          },
                        );
                      case UserFeedType.comment:
                      case UserFeedType.reply:
                        return PostCommentScreen(item.postType, item.id);
                    }
                  }),
                );
              }

              return Wrapper(
                shouldWrap: item is! CommentModel,
                parentBuilder: (child) => Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(onTap: onClick, child: child)),
                child: switch (widget.mode) {
                  UserFeedType.thread => PostItem(
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
                  UserFeedType.microblog => PostItem(
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
                  UserFeedType.comment => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: PostComment(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        onClick: onClick,
                      )),
                  UserFeedType.reply => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: PostComment(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        onClick: onClick,
                      )),
                  UserFeedType.follower => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        if (item.avatar != null)
                          Avatar(
                            item.avatar,
                            radius: 16,
                          ),
                        Container(width: 8 + (item.avatar != null ? 0 : 32)),
                        Expanded(
                            child: Text(item.name,
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 12),
                        SubscriptionButton(
                          subsCount: item.followersCount!,
                          isSubed: item.isFollowedByUser == true,
                          onPress: whenLoggedIn(context, () async {
                            var newValue = await context
                                .read<SettingsController>()
                                .api
                                .users
                                .follow(item.id, !item.isFollowedByUser!);
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          }),
                        )
                      ]),
                    ),
                  UserFeedType.following => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        if (item.avatar != null)
                          Avatar(
                            item.avatar,
                            radius: 16,
                          ),
                        Container(width: 8 + (item.avatar != null ? 0 : 32)),
                        Expanded(
                            child: Text(item.name,
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 12),
                        SubscriptionButton(
                          subsCount: item.followersCount!,
                          isSubed: item.isFollowedByUser == true,
                          onPress: whenLoggedIn(context, () async {
                            var newValue = await context
                                .read<SettingsController>()
                                .api
                                .users
                                .follow(item.id, !item.isFollowedByUser!);
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          }),
                        )
                      ]),
                    ),
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
