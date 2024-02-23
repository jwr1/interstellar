import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/feed/post_comment.dart';
import 'package:interstellar/src/screens/feed/post_comment_screen.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
import 'package:interstellar/src/screens/feed/post_page.dart';
import 'package:interstellar/src/screens/profile/message_thread_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/image_selector.dart';
import 'package:interstellar/src/widgets/markdown.dart';
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
        body: _data == null
            ? const Center(child: CircularProgressIndicator())
            : DefaultTabController(
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
                                maxHeight:
                                    MediaQuery.of(context).size.height / 3,
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
                              ),
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
                                                        .read<
                                                            SettingsController>()
                                                        .api
                                                        .users
                                                        .updateProfile(
                                                            _aboutTextController!
                                                                .text);
                                                    if (!mounted) return;
                                                    if (_avatarFile != null) {
                                                      user = await context
                                                          .read<
                                                              SettingsController>()
                                                          .api
                                                          .users
                                                          .updateAvatar(
                                                              _avatarFile!);
                                                    }
                                                    if (!mounted) return;
                                                    if (_coverFile != null) {
                                                      user = await context
                                                          .read<
                                                              SettingsController>()
                                                          .api
                                                          .users
                                                          .updateCover(
                                                              _coverFile!);
                                                    }

                                                    setState(() {
                                                      if (user != null) {
                                                        _data = user;
                                                      }
                                                      _aboutTextController!
                                                          .dispose();
                                                      _aboutTextController =
                                                          null;
                                                      _coverFile = null;
                                                      _avatarFile = null;
                                                    });
                                                  },
                                                  child: const Text("Save")),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _aboutTextController!
                                                          .dispose();
                                                      _aboutTextController =
                                                          null;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _data!.name.contains('@')
                                            ? _data!.name.split('@')[1]
                                            : _data!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text('Copied')));
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
                                  const Spacer(),
                                  if (_data!.followersCount != null)
                                    OutlinedButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                _data!.isFollowedByUser == true
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                    : null),
                                      ),
                                      onPressed:
                                          whenLoggedIn(context, () async {
                                        var newValue = await context
                                            .read<SettingsController>()
                                            .api
                                            .users
                                            .follow(_data!.id,
                                                !_data!.isFollowedByUser!);
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
                                              ' ${intFormat(_data!.followersCount!)}'),
                                        ],
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
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                _data!.isBlockedByUser == true
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                    : Theme.of(context)
                                                        .disabledColor),
                                      ),
                                    ),
                                  if (!_data!.name.contains('@'))
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
                              if (_data!.about != null ||
                                  _aboutTextController != null)
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
                          if (context
                                  .watch<SettingsController>()
                                  .serverSoftware !=
                              ServerSoftware.lemmy)
                            const Tab(
                              text: 'Microblogs',
                              icon: Icon(Icons.chat),
                            ),
                          const Tab(
                            text: 'Comments',
                            icon: Icon(Icons.comment),
                          ),
                          if (context
                                  .watch<SettingsController>()
                                  .serverSoftware !=
                              ServerSoftware.lemmy)
                            const Tab(
                              text: 'Replies',
                              icon: Icon(Icons.comment),
                            ),
                          if (context
                                  .watch<SettingsController>()
                                  .serverSoftware !=
                              ServerSoftware.lemmy)
                            const Tab(
                              text: 'Followers',
                              icon: Icon(Icons.people),
                            ),
                          if (context
                                  .watch<SettingsController>()
                                  .serverSoftware !=
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
                      data: _data,
                    ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      UserScreenBody(
                        mode: UserFeedType.microblog,
                        data: _data,
                      ),
                    UserScreenBody(
                      mode: UserFeedType.comment,
                      data: _data,
                    ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      UserScreenBody(
                        mode: UserFeedType.reply,
                        data: _data,
                      ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      UserScreenBody(
                        mode: UserFeedType.follower,
                        data: _data,
                      ),
                    if (context.watch<SettingsController>().serverSoftware !=
                        ServerSoftware.lemmy)
                      UserScreenBody(
                        mode: UserFeedType.following,
                        data: _data,
                      ),
                  ]),
                ),
              ));
  }
}

class UserScreenBody extends StatefulWidget {
  final UserFeedType mode;
  final DetailedUserModel? data;

  const UserScreenBody({
    super.key,
    required this.mode,
    this.data,
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
          context.read<SettingsController>().api.comments.listFromUser(
                PostType.thread,
                widget.data!.id,
                page: pageKey,
                sort: CommentSort.newest,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        UserFeedType.reply =>
          context.read<SettingsController>().api.comments.listFromUser(
                PostType.microblog,
                widget.data!.id,
                page: pageKey,
                sort: CommentSort.newest,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        UserFeedType.follower =>
          context.read<SettingsController>().api.users.listFollowers(
                widget.data!.id,
                page: pageKey,
              ),
        UserFeedType.following =>
          context.read<SettingsController>().api.users.listFollowing(
                widget.data!.id,
                page: pageKey,
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
        Object newPage => []
      });

      _pagingController.appendPage(
          newItems,
          (switch (newPage) {
            PostListModel newPage => newPage.nextPage,
            CommentListModel newPage => newPage.nextPage,
            DetailedUserListModel newPage => newPage.nextPage,
            Object newPage => ''
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
                        return PostPage(item, (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        });
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
                        OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll(
                                item.isFollowedByUser == true
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
                                .follow(item.id, !item.isFollowedByUser!);
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          }),
                          child: Row(
                            children: [
                              const Icon(Icons.group),
                              Text(' ${intFormat(item.followersCount)}'),
                            ],
                          ),
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
                        OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll(
                                item.isFollowedByUser == true
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
                                .follow(item.id, !item.isFollowedByUser!);
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          }),
                          child: Row(
                            children: [
                              const Icon(Icons.group),
                              Text(' ${intFormat(item.followersCount)}'),
                            ],
                          ),
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
