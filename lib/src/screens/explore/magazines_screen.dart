import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/debouncer.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
import 'package:provider/provider.dart';

class MagazinesScreen extends StatefulWidget {
  final bool onlySubbed;

  const MagazinesScreen({
    super.key,
    this.onlySubbed = false,
  });

  @override
  State<MagazinesScreen> createState() => _MagazinesScreenState();
}

class _MagazinesScreenState extends State<MagazinesScreen> {
  APIMagazinesFilter filter = APIMagazinesFilter.all;
  APIMagazinesSort sort = APIMagazinesSort.hot;
  String search = '';
  final searchDebounce = Debouncer(duration: const Duration(milliseconds: 500));

  final PagingController<String, DetailedMagazineModel> _pagingController =
      PagingController(firstPageKey: '');

  @override
  void initState() {
    super.initState();

    if (widget.onlySubbed) {
      filter = APIMagazinesFilter.subscribed;
    }

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage =
          await context.read<SettingsController>().api.magazines.list(
                page: nullIfEmpty(pageKey),
                filter: filter,
                sort: sort,
                search: nullIfEmpty(search),
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
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: DropdownButton<APIMagazinesFilter>(
                        value: filter,
                        onChanged: (newFilter) {
                          if (newFilter != null) {
                            setState(() {
                              filter = newFilter;
                              _pagingController.refresh();
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: APIMagazinesFilter.all,
                            child: Text(l(context).filter_all),
                          ),
                          DropdownMenuItem(
                            value: APIMagazinesFilter.local,
                            child: Text(l(context).filter_local),
                          ),
                          ...(whenLoggedIn(context, [
                                DropdownMenuItem(
                                  value: APIMagazinesFilter.subscribed,
                                  child: Text(l(context).filter_subscribed),
                                ),
                                DropdownMenuItem(
                                  value: APIMagazinesFilter.moderated,
                                  child: Text(l(context).filter_moderated),
                                ),
                                if (context
                                        .read<SettingsController>()
                                        .serverSoftware !=
                                    ServerSoftware.lemmy)
                                  DropdownMenuItem(
                                    value: APIMagazinesFilter.blocked,
                                    child: Text(l(context).filter_blocked),
                                  ),
                              ]) ??
                              [])
                        ],
                      ),
                    ),
                    ...(context.watch<SettingsController>().serverSoftware ==
                                ServerSoftware.lemmy ||
                            filter == APIMagazinesFilter.all ||
                            filter == APIMagazinesFilter.local
                        ? [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: DropdownButton<APIMagazinesSort>(
                                value: sort,
                                onChanged: (newSort) {
                                  if (newSort != null) {
                                    setState(() {
                                      sort = newSort;
                                      _pagingController.refresh();
                                    });
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: APIMagazinesSort.hot,
                                    child: Text(l(context).sort_hot),
                                  ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.top,
                                      child: Text(l(context).sort_top),
                                    ),
                                  DropdownMenuItem(
                                    value: APIMagazinesSort.active,
                                    child: Text(l(context).sort_active),
                                  ),
                                  DropdownMenuItem(
                                    value: APIMagazinesSort.newest,
                                    child: Text(l(context).sort_newest),
                                  ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.oldest,
                                      child: Text(l(context).sort_oldest),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.scaled,
                                      child: Text(l(context).sort_scaled),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.controversial,
                                      child:
                                          Text(l(context).sort_controversial),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.commented,
                                      child: Text(l(context).sort_commented),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.newComments,
                                      child: Text(l(context).sort_newComments),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topHour,
                                      child: Text(l(context).sort_topHour),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topSixHour,
                                      child: Text(l(context).sort_topSixHour),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topTwelveHour,
                                      child:
                                          Text(l(context).sort_topTwelveHour),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topDay,
                                      child: Text(l(context).sort_topDay),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topWeek,
                                      child: Text(l(context).sort_topWeek),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topMonth,
                                      child: Text(l(context).sort_topMonth),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topThreeMonths,
                                      child:
                                          Text(l(context).sort_topThreeMonths),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topSixMonths,
                                      child: Text(l(context).sort_topSixMonths),
                                    ),
                                  if (context
                                          .watch<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy)
                                    DropdownMenuItem(
                                      value: APIMagazinesSort.topNineMonths,
                                      child:
                                          Text(l(context).sort_topNineMonths),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 128,
                              child: TextFormField(
                                initialValue: search,
                                onChanged: (newSearch) {
                                  searchDebounce.run(() {
                                    search = newSearch;
                                    _pagingController.refresh();
                                  });
                                },
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    label: Text(l(context).search)),
                              ),
                            ),
                          ]
                        : []),
                  ],
                ),
              ),
            ),
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DetailedMagazineModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MagazineScreen(
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
                    Expanded(
                      child: Row(
                        children: [
                          if (item.icon != null) Avatar(item.icon, radius: 16),
                          Container(width: 8 + (item.icon != null ? 0 : 32)),
                          Flexible(
                              child: Text(item.name,
                                  overflow: TextOverflow.ellipsis)),
                          if (item.isPostingRestrictedToMods)
                            const PostingRestrictedIndicator(),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.feed),
                        Container(
                          width: 4,
                        ),
                        Text(intFormat(item.threadCount)),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment),
                        Container(
                          width: 4,
                        ),
                        Text(intFormat(item.threadCommentCount)),
                        const SizedBox(width: 12),
                        SubscriptionButton(
                          subsCount: item.subscriptionsCount,
                          isSubed: item.isUserSubscribed == true,
                          onPress: whenLoggedIn(context, () async {
                            var newValue = await context
                                .read<SettingsController>()
                                .api
                                .magazines
                                .subscribe(item.id, !item.isUserSubscribed!);
                            var newList = _pagingController.itemList;
                            newList![index] = newValue;
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          }),
                        ),
                      ],
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
