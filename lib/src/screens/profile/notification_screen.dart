import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/notifications.dart';
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/screens/profile/notification_item.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsFilter filter = NotificationsFilter.all;

  final PagingController<int, NotificationModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await fetchNotifications(
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
          _pagingController.itemList?.map((e) => e.notificationId) ?? [];
      final newItems = newPage.items
          .where((e) => !currentItemIds.contains(e.notificationId))
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
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButton<NotificationsFilter>(
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
                          value: NotificationsFilter.all,
                          child: Text('All'),
                        ),
                        DropdownMenuItem(
                          value: NotificationsFilter.new_,
                          child: Text('New'),
                        ),
                        DropdownMenuItem(
                          value: NotificationsFilter.read,
                          child: Text('Read'),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                      onPressed: () async {
                        await putNotificationReadAll(
                          context.read<SettingsController>().httpClient,
                          context.read<SettingsController>().instanceHost,
                        );
                        _pagingController.refresh();
                      },
                      child: const Text('Mark all as read'))
                ],
              ),
            ),
          ),
          PagedSliverList<int, NotificationModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<NotificationModel>(
              itemBuilder: (context, item, index) =>
                  NotificationItem(item, (newValue) {
                var newList = _pagingController.itemList;
                newList![index] = newValue;
                setState(() {
                  _pagingController.itemList = newList;
                });
              }),
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
