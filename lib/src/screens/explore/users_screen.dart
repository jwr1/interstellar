import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  api_users.UsersFilter filter = api_users.UsersFilter.all;

  final PagingController<int, DetailedUserModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await api_users.fetchUsers(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        page: pageKey,
        filter: filter,
      );

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;
      // Prevent duplicates
      final currentItemIds =
          _pagingController.itemList?.map((e) => e.userId) ?? [];
      final newItems = newPage.items
          .where((e) => !currentItemIds.contains(e.userId))
          .toList();

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ...whenLoggedIn(context, [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: DropdownButton<api_users.UsersFilter>(
                            value: filter,
                            onChanged: (newFilter) {
                              if (newFilter != null) {
                                setState(() {
                                  filter = newFilter;
                                  _pagingController.refresh();
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: api_users.UsersFilter.all,
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: api_users.UsersFilter.followed,
                                child: Text('Followed'),
                              ),
                              DropdownMenuItem(
                                value: api_users.UsersFilter.followers,
                                child: Text('Followers'),
                              ),
                              DropdownMenuItem(
                                value: api_users.UsersFilter.blocked,
                                child: Text('Blocked'),
                              ),
                            ],
                          ),
                        )
                      ]) ??
                      [],
                ],
              ),
            ),
          ),
          PagedSliverList<int, DetailedUserModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DetailedUserModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserScreen(
                        item.userId,
                        initData: item,
                        onUpdate: (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
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
                ),
              ),
            ),
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
