import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  final bool onlySubbed;

  const UsersScreen({
    super.key,
    this.onlySubbed = false,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  api_users.UsersFilter filter = api_users.UsersFilter.all;

  final PagingController<String, DetailedUserModel> _pagingController =
      PagingController(firstPageKey: '');

  @override
  void initState() {
    super.initState();

    if (widget.onlySubbed) {
      filter = api_users.UsersFilter.followed;
    }

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage = await context.read<SettingsController>().api.users.list(
            page: nullIfEmpty(pageKey),
            filter: filter,
          );

      // Check BuildContext
      if (!mounted) return;

      // Prevent duplicates
      final currentItemIds = _pagingController.itemList?.map((e) => e.id) ?? [];
      final newItems =
          newPage.items.where((e) => !currentItemIds.contains(e.id)).toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
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
          if (!widget.onlySubbed)
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
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DetailedUserModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserScreen(
                        item.id,
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
                    if (item.avatar != null)
                      Avatar(
                        item.avatar,
                        radius: 16,
                      ),
                    Container(width: 8 + (item.avatar != null ? 0 : 32)),
                    Expanded(
                        child:
                            Text(item.name, overflow: TextOverflow.ellipsis)),
                    if (item.followersCount != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: SubscriptionButton(
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
