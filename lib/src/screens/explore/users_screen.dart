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
  final PagingController<int, DetailedUserModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await api_users.fetchUsers(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        page: pageKey,
      );

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
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          PagedSliverList<int, DetailedUserModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DetailedUserModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserScreen(
                        item.userId,
                        data: item,
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
                  padding: const EdgeInsets.all(12.0),
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
                              ? MaterialStatePropertyAll(Colors.purple.shade400)
                              : null),
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
