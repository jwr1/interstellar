import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/api/search.dart' as api_search;
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/entries/entry_comment_screen.dart';
import 'package:interstellar/src/screens/entries/entry_page.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/posts/post_comment_screen.dart';
import 'package:interstellar/src/screens/posts/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

import '../../models/entry.dart';
import '../entries/entry_comment.dart';
import '../entries/entry_item.dart';
import '../posts/post_comment.dart';
import '../posts/post_item.dart';
import 'magazine_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String search = "";

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await api_search.search(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        page: pageKey,
        search: search,
      );

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;

      if (isLastPage) {
        _pagingController.appendLastPage(newPage.items);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newPage.items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: search,
          onFieldSubmitted: (newSearch) {
            setState(() {
              search = newSearch;
            });
            _pagingController.refresh();
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(),
            label: Text("Search"),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
                itemBuilder: (context, item, index) {
              onClick() {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    switch (item) {
                      case DetailedUserModel item:
                        return UserScreen(
                          item.userId,
                          initData: item,
                          onUpdate: (newValue) {
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          },
                        );
                      case DetailedMagazineModel item:
                        return MagazineScreen(
                          item.magazineId,
                          initData: item,
                          onUpdate: (newValue) {
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          },
                        );
                      case EntryModel item:
                        return EntryPage(item, (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        });
                      case EntryCommentModel item:
                        return EntryCommentScreen(item.commentId);
                      case PostModel item:
                        return PostPage(item, (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        });
                      case PostCommentModel item:
                        return PostCommentScreen(item.commentId);
                      case _:
                        throw "Unrecognized search item";
                    }
                  }),
                );
              }

              return Wrapper(
                shouldWrap:
                    !(item is EntryCommentModel || item is PostCommentModel),
                parentBuilder: (child) => Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(onTap: onClick, child: child),
                ),
                child: switch (item) {
                  EntryModel item => EntryItem(
                      item,
                      (newValue) {
                        var newList = _pagingController.itemList;
                        newList![index] = newValue;
                        setState(() {
                          _pagingController.itemList = newList;
                        });
                      },
                      isPreview: true,
                    ),
                  EntryCommentModel item => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: EntryComment(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        onClick: onClick,
                      ),
                    ),
                  PostModel item => PostItem(
                      item,
                      (newValue) {
                        var newList = _pagingController.itemList;
                        newList![index] = newValue;
                        setState(() {
                          _pagingController.itemList = newList;
                        });
                      },
                    ),
                  PostCommentModel item => Padding(
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
                      ),
                    ),
                  DetailedUserModel item => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        if (item.avatar?.storageUrl != null)
                          Avatar(
                            item.avatar!.storageUrl,
                            radius: 16,
                          ),
                        Container(
                            width:
                                8 + (item.avatar?.storageUrl != null ? 0 : 32)),
                        Expanded(
                            child: Text(item.username,
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
                            var newValue = await api_users.putFollow(
                                context.read<SettingsController>().httpClient,
                                context.read<SettingsController>().instanceHost,
                                item.userId,
                                !item.isFollowedByUser!);
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
                  DetailedMagazineModel item => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        if (item.icon?.storageUrl != null)
                          Avatar(item.icon!.storageUrl, radius: 16),
                        Container(
                            width:
                                8 + (item.icon?.storageUrl != null ? 0 : 32)),
                        Expanded(
                            child: Text(item.name,
                                overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.feed),
                        Container(
                          width: 4,
                        ),
                        Text(intFormat(item.entryCount)),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment),
                        Container(
                          width: 4,
                        ),
                        Text(intFormat(item.entryCommentCount)),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll(
                                item.isUserSubscribed == true
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : null),
                          ),
                          onPressed: whenLoggedIn(context, () async {
                            var newValue = await api_magazines.putSubscribe(
                                context.read<SettingsController>().httpClient,
                                context.read<SettingsController>().instanceHost,
                                item.magazineId,
                                !item.isUserSubscribed!);
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          }),
                          child: Row(
                            children: [
                              const Icon(Icons.group),
                              Text(' ${intFormat(item.subscriptionsCount)}'),
                            ],
                          ),
                        )
                      ]),
                    ),
                  _ => const Text("Unknown"),
                },
              );
            }),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
