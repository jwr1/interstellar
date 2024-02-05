import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/search.dart' as api_search;
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
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
            label: Text("Search")
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          PagedSliverList(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<dynamic>(
                itemBuilder: (context, item, index) => InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          if (item is DetailedUserModel) {
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
                          } else if (item is DetailedMagazineModel) {
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
                          } else if (item is EntryModel) {
                            return EntryPage(item, (newValue) {
                              var newList = _pagingController.itemList;
                              newList![index] = newValue;
                              setState(() {
                                _pagingController.itemList = newList;
                              });
                            });
                          } else if (item is EntryCommentModel) {
                            return EntryCommentScreen(item.commentId);
                          } else if (item is PostModel) {
                            return PostPage(item, (newValue) {
                              var newList = _pagingController.itemList;
                              newList![index] = newValue;
                              setState(() {
                                _pagingController.itemList = newList;
                              });
                            });
                          } else if (item is PostCommentModel) {
                            return PostCommentScreen(item.commentId);
                          }
                          throw "Unrecognised search item";
                        }
                      )
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    clipBehavior: Clip.antiAlias,
                    child: item is EntryModel
                        ? EntryItem(
                            item, (newValue) {
                              var newList = _pagingController.itemList;
                              newList![index] = newValue;
                              setState(() {
                                _pagingController.itemList = newList;
                              });
                            },
                            isPreview: true,
                          )
                        : item is EntryCommentModel
                        ? EntryComment(item, (newValue) {
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          })
                        : item is PostModel
                        ? PostItem(
                            item, (newValue) {
                              var newList = _pagingController.itemList;
                              newList![index] = newValue;
                              setState(() {
                                _pagingController.itemList = newList;
                              });
                            },
                          )
                        : item is PostCommentModel
                        ? PostComment(item, (newValue) {
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          })
                        : item is DetailedUserModel
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              if (item.avatar?.storageUrl != null)
                                Avatar(
                                  item.avatar!.storageUrl,
                                  radius: 16,
                                ),
                              Container(
                                width: 8 + (item.avatar?.storageUrl != null ? 0 : 32)),
                              Expanded(
                                child: Text(item.username,
                                    overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                style: ButtonStyle(
                                  foregroundColor: item.isFollowedByUser == true
                                    ? null
                                    : MaterialStatePropertyAll(
                                      Theme.of(context).disabledColor)),
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
                          )
                        : item is DetailedMagazineModel
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              if (item.icon?.storageUrl != null)
                                Avatar(item.icon!.storageUrl, radius: 16),
                              Container(
                                width: 8 + (item.icon?.storageUrl != null ? 0 : 32)),
                              Expanded(
                                child:
                                Text(item.name, overflow: TextOverflow.ellipsis)),
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
                                  foregroundColor: item.isUserSubscribed == true
                                    ? null
                                    : MaterialStatePropertyAll(
                                      Theme.of(context).disabledColor)),
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
                          )
                        : const Text("Unknown"),
                  ),
                )
              )
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
