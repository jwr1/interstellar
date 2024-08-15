import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/notifications.dart';
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';

import './notification_count_controller.dart';
import './notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsFilter filter = NotificationsFilter.all;

  final PagingController<String, NotificationModel> _pagingController =
      PagingController(firstPageKey: '');

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    // Reload notification count on screen load or when screen is refreshed
    if (pageKey.isEmpty) {
      context.read<NotificationCountController>().reload();
    }

    try {
      final newPage = await context
          .read<SettingsController>()
          .api
          .notifications
          .list(page: nullIfEmpty(pageKey), filter: filter);

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
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
                      await context
                          .read<SettingsController>()
                          .api
                          .notifications
                          .putReadAll();
                      _pagingController.refresh();

                      if (!mounted) return;
                      context.read<NotificationCountController>().reload();
                    },
                    child: const Text('Mark all as read'),
                  ),
                  if (Platform.isAndroid)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: MenuAnchor(
                        builder: (BuildContext context,
                            MenuController controller, Widget? child) {
                          return OutlinedButton(
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Push'),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                          );
                        },
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () async {
                              final permissionsResult =
                                  await FlutterLocalNotificationsPlugin()
                                      .resolvePlatformSpecificImplementation<
                                          AndroidFlutterLocalNotificationsPlugin>()
                                      ?.requestNotificationsPermission();

                              if (permissionsResult == false) {
                                throw Exception(
                                    'Notification permissions denied');
                              }

                              if (!mounted) return;
                              await UnifiedPush.registerAppWithDialog(
                                context,
                                context
                                    .read<SettingsController>()
                                    .selectedAccount,
                                [featureAndroidBytesMessage],
                              );
                            },
                            child: const Text('Register'),
                          ),
                          MenuItemButton(
                            onPressed: () async {
                              await UnifiedPush.unregister(
                                context
                                    .read<SettingsController>()
                                    .selectedAccount,
                              );

                              if (!mounted) return;
                              await context
                                  .read<SettingsController>()
                                  .api
                                  .notifications
                                  .pushDelete();
                            },
                            child: const Text('Unregister'),
                          ),
                          MenuItemButton(
                            onPressed: () async {
                              await context
                                  .read<SettingsController>()
                                  .api
                                  .notifications
                                  .pushTest();
                            },
                            child: const Text('Test notification'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          PagedSliverList(
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
