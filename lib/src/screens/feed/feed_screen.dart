import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/create_screen.dart';
import 'package:interstellar/src/screens/feed/nav_drawer.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
import 'package:interstellar/src/screens/feed/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/actions.dart';
import 'package:interstellar/src/widgets/floating_menu.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  final FeedSource? source;
  final int? sourceId;
  final String? title;
  final Widget? details;
  final DetailedMagazineModel? createPostMagazine;

  const FeedScreen({
    super.key,
    this.source,
    this.sourceId,
    this.title,
    this.details,
    this.createPostMagazine,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _fabKey = GlobalKey<FloatingMenuState>();
  final List<GlobalKey<_FeedScreenBodyState>> _feedKeyList = [];
  late FeedSource _filter;
  late PostType _mode;
  late FeedSort _sort;

  _getFeedKey(int index) {
    while (index >= _feedKeyList.length) {
      _feedKeyList.add(GlobalKey());
    }
    return _feedKeyList[index];
  }

  @override
  void initState() {
    super.initState();

    _filter = whenLoggedIn(
            context, context.read<SettingsController>().defaultFeedFilter) ??
        FeedSource.all;
    _mode = context.read<SettingsController>().serverSoftware !=
            ServerSoftware.lemmy
        ? context.read<SettingsController>().defaultFeedType
        : PostType.thread;
    _sort = widget.source == null
        ? _mode == PostType.thread
            ? context.read<SettingsController>().defaultThreadsFeedSort
            : context.read<SettingsController>().defaultMicroblogFeedSort
        : context.read<SettingsController>().defaultExploreFeedSort;
  }

  @override
  Widget build(BuildContext context) {
    final currentFeedModeOption = feedTypeSelect(context).getOption(_mode);
    final currentFeedSortOption = feedSortSelect(context).getOption(_sort);

    final actions = [
      feedActionCreatePost(context).withProps(
        context.watch<SettingsController>().isLoggedIn
            ? context.watch<SettingsController>().feedActionCreatePost
            : ActionLocation.hide,
        () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateScreen(
                _mode,
                magazineId: widget.createPostMagazine?.id,
                magazineName: widget.createPostMagazine?.name,
              ),
            ),
          );
        },
      ),
      feedActionSetFilter(context).withProps(
        whenLoggedIn(context, widget.source != null) ?? true
            ? ActionLocation.hide
            : parseEnum(
                ActionLocation.values,
                ActionLocation.hide,
                context.watch<SettingsController>().feedActionSetFilter.name,
              ),
        () async {
          final newFilter =
              await feedFilterSelect(context).askSelection(context, _filter);

          if (newFilter != null && newFilter != _filter) {
            setState(() {
              _filter = newFilter;
            });
          }
        },
      ),
      feedActionSetSort(context).withProps(
        parseEnum(
          ActionLocation.values,
          ActionLocation.hide,
          context.watch<SettingsController>().feedActionSetSort.name,
        ),
        () async {
          final newSort =
              await feedSortSelect(context).askSelection(context, _sort);

          if (newSort != null && newSort != _sort) {
            setState(() {
              _sort = newSort;
            });
          }
        },
      ),
      feedActionSetType(context).withProps(
        widget.source == FeedSource.domain &&
                context.watch<SettingsController>().serverSoftware ==
                    ServerSoftware.lemmy
            ? ActionLocation.hide
            : parseEnum(
                ActionLocation.values,
                ActionLocation.hide,
                context.watch<SettingsController>().feedActionSetType.name,
              ),
        () async {
          final newMode =
              await feedTypeSelect(context).askSelection(context, _mode);

          if (newMode != null && newMode != _mode) {
            setState(() {
              _mode = newMode;
              _sort = widget.source == null
                  ? _mode == PostType.thread
                      ? context
                          .read<SettingsController>()
                          .defaultThreadsFeedSort
                      : context
                          .read<SettingsController>()
                          .defaultMicroblogFeedSort
                  : context.read<SettingsController>().defaultExploreFeedSort;
            });
          }
        },
      ),
      feedActionRefresh(context).withProps(
        context.watch<SettingsController>().feedActionRefresh,
        () {
          for (var key in _feedKeyList) {
            key.currentState?.refresh();
          }
        },
      ),
      feedActionBackToTop(context).withProps(
        context.watch<SettingsController>().feedActionBackToTop,
        () {
          for (var key in _feedKeyList) {
            key.currentState?.backToTop();
          }
        },
      ),
      feedActionExpandFab(context).withProps(
        context.watch<SettingsController>().feedActionExpandFab,
        () {
          _fabKey.currentState?.toggle();
        },
      ),
    ];

    final tabsAction = [
      if (context.watch<SettingsController>().feedActionSetFilter ==
              ActionLocationWithTabs.tabs &&
          widget.source == null &&
          context.watch<SettingsController>().isLoggedIn)
        actions.firstWhere(
            (action) => action.name == feedActionSetFilter(context).name),
      if (context.watch<SettingsController>().feedActionSetType ==
          ActionLocationWithTabs.tabs)
        actions.firstWhere(
            (action) => action.name == feedActionSetType(context).name),
    ].firstOrNull;

    return Wrapper(
      shouldWrap: tabsAction != null,
      parentBuilder: (child) => DefaultTabController(
        initialIndex: switch (tabsAction?.name) {
          String name when name == feedActionSetFilter(context).name =>
            feedFilterSelect(context)
                .options
                .asMap()
                .entries
                .firstWhere((entry) =>
                    entry.value.value ==
                    context.watch<SettingsController>().defaultFeedFilter)
                .key,
          String name when name == feedActionSetType(context).name =>
            feedTypeSelect(context)
                .options
                .asMap()
                .entries
                .firstWhere((entry) =>
                    entry.value.value ==
                    (context.watch<SettingsController>().serverSoftware !=
                            ServerSoftware.lemmy
                        ? context.watch<SettingsController>().defaultFeedType
                        : PostType.thread))
                .key,
          _ => 0
        },
        length: switch (tabsAction?.name) {
          String name when name == feedActionSetFilter(context).name =>
            feedFilterSelect(context).options.length,
          String name when name == feedActionSetType(context).name =>
            feedTypeSelect(context).options.length,
          _ => 0
        },
        child: child,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.title ??
                  context.watch<SettingsController>().selectedAccount +
                      (context.watch<SettingsController>().isLoggedIn
                          ? ''
                          : ' (${l(context).guest})'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Text(currentFeedModeOption.title),
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
          actions: actions
              .where((action) => action.location == ActionLocation.appBar)
              .map(
                (action) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    tooltip: action.name,
                    icon: Icon(action.icon),
                    onPressed: action.callback,
                  ),
                ),
              )
              .toList(),
          bottom: tabsAction == null
              ? null
              : TabBar(
                  tabs: switch (tabsAction.name) {
                    String name
                        when name == feedActionSetFilter(context).name =>
                      feedFilterSelect(context)
                          .options
                          .map(
                            (option) => Tab(
                              text: option.title.substring(0, 3),
                              icon: Icon(option.icon),
                            ),
                          )
                          .toList(),
                    String name when name == feedActionSetType(context).name =>
                      feedTypeSelect(context)
                          .options
                          .map(
                            (option) => Tab(
                              text: option.title,
                              icon: Icon(option.icon),
                            ),
                          )
                          .toList(),
                    _ => []
                  },
                ),
        ),
        body: tabsAction == null
            ? FeedScreenBody(
                key: _getFeedKey(0),
                source: widget.source ?? _filter,
                sourceId: widget.sourceId,
                sort: _sort,
                mode: _mode,
                details: widget.details,
              )
            : TabBarView(
                children: switch (tabsAction.name) {
                  String name when name == feedActionSetFilter(context).name =>
                    [
                      FeedScreenBody(
                        key: _getFeedKey(0),
                        source: FeedSource.subscribed,
                        sort: _sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(1),
                        source: FeedSource.moderated,
                        sort: _sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(2),
                        source: FeedSource.favorited,
                        sort: _sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(3),
                        source: FeedSource.all,
                        sort: _sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                    ],
                  String name when name == feedActionSetType(context).name => [
                      FeedScreenBody(
                        key: _getFeedKey(0),
                        source: _filter,
                        sort: _sort,
                        mode: PostType.thread,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(1),
                        source: _filter,
                        sort: _sort,
                        mode: PostType.microblog,
                        details: widget.details,
                      ),
                    ],
                  _ => [],
                },
              ),
        floatingActionButton: FloatingMenu(
          key: _fabKey,
          tapAction: actions
              .where(
                (action) => action.location == ActionLocation.fabTap,
              )
              .firstOrNull,
          holdAction: actions
              .where(
                (action) => action.location == ActionLocation.fabHold,
              )
              .firstOrNull,
          menuActions: actions
              .where(
                (action) => action.location == ActionLocation.fabMenu,
              )
              .toList(),
        ),
        drawer: widget.sourceId != null ? null : const NavDrawer(),
      ),
    );
  }
}

SelectionMenu<PostType> feedTypeSelect(BuildContext context) => SelectionMenu(
      l(context).feedType,
      [
        SelectionMenuItem(
          value: PostType.thread,
          title: l(context).threads,
          icon: Icons.feed,
        ),
        SelectionMenuItem(
          value: PostType.microblog,
          title: l(context).microblog,
          icon: Icons.chat,
        ),
      ],
    );

SelectionMenu<FeedSort> feedSortSelect(BuildContext context) => SelectionMenu(
      l(context).sort,
      [
        SelectionMenuItem(
          value: FeedSort.hot,
          title: l(context).sort_hot,
          icon: Icons.local_fire_department,
        ),
        SelectionMenuItem(
          value: FeedSort.top,
          title: l(context).sort_top,
          icon: Icons.trending_up,
        ),
        SelectionMenuItem(
          value: FeedSort.newest,
          title: l(context).sort_newest,
          icon: Icons.auto_awesome_rounded,
        ),
        SelectionMenuItem(
          value: FeedSort.active,
          title: l(context).sort_active,
          icon: Icons.rocket_launch,
        ),
        SelectionMenuItem(
          value: FeedSort.commented,
          title: l(context).sort_commented,
          icon: Icons.chat,
        ),
        SelectionMenuItem(
          value: FeedSort.oldest,
          title: l(context).sort_oldest,
          icon: Icons.access_time_outlined,
        ),

        //lemmy specific
        SelectionMenuItem(
          value: FeedSort.newComments,
          title: l(context).sort_newComments,
          icon: Icons.mark_chat_unread,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.controversial,
          title: l(context).sort_controversial,
          icon: Icons.thumbs_up_down,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.scaled,
          title: l(context).sort_scaled,
          icon: Icons.scale,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topDay,
          title: l(context).sort_topDay,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topWeek,
          title: l(context).sort_topWeek,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topMonth,
          title: l(context).sort_topMonth,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topYear,
          title: l(context).sort_topYear,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topHour,
          title: l(context).sort_topHour,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topSixHour,
          title: l(context).sort_topSixHour,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topTwelveHour,
          title: l(context).sort_topTwelveHour,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topThreeMonths,
          title: l(context).sort_topThreeMonths,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topSixMonths,
          title: l(context).sort_topSixMonths,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topNineMonths,
          title: l(context).sort_topNineMonths,
          icon: Icons.trending_up,
          validSoftware: ServerSoftware.lemmy,
        ),
      ],
    );

SelectionMenu<FeedSource> feedFilterSelect(BuildContext context) =>
    SelectionMenu(
      l(context).filter,
      [
        SelectionMenuItem(
          value: FeedSource.subscribed,
          title: l(context).filter_subscribed,
          icon: Icons.group,
        ),
        SelectionMenuItem(
          value: FeedSource.moderated,
          title: l(context).filter_moderated,
          icon: Icons.lock,
        ),
        SelectionMenuItem(
          value: FeedSource.favorited,
          title: l(context).filter_favorited,
          icon: Icons.favorite,
        ),
        SelectionMenuItem(
          value: FeedSource.all,
          title: l(context).filter_all,
          icon: Icons.newspaper,
        ),
      ],
    );

class FeedScreenBody extends StatefulWidget {
  final FeedSource source;
  final int? sourceId;
  final FeedSort sort;
  final PostType mode;
  final Widget? details;

  const FeedScreenBody({
    super.key,
    required this.source,
    this.sourceId,
    required this.sort,
    required this.mode,
    this.details,
  });

  @override
  State<FeedScreenBody> createState() => _FeedScreenBodyState();
}

class _FeedScreenBodyState extends State<FeedScreenBody> {
  final _pagingController =
      PagingController<String, PostModel>(firstPageKey: '');
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      PostListModel newPage = await (switch (widget.mode) {
        PostType.thread => context.read<SettingsController>().api.threads.list(
              widget.source,
              sourceId: widget.sourceId,
              page: nullIfEmpty(pageKey),
              sort: widget.sort,
              usePreferredLangs: whenLoggedIn(context,
                  context.read<SettingsController>().useAccountLangFilter),
              langs: context.read<SettingsController>().langFilter.toList(),
            ),
        PostType.microblog =>
          context.read<SettingsController>().api.microblogs.list(
                widget.source,
                sourceId: widget.sourceId,
                page: nullIfEmpty(pageKey),
                sort: widget.sort,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
      });

      // Check BuildContext
      if (!mounted) return;

      // Prevent duplicates
      List<PostModel> newItems = [];
      final currentItemIds =
          _pagingController.itemList?.map((post) => post.id) ?? [];
      newItems = newPage.items
          .where((post) => !currentItemIds.contains(post.id))
          .where((post) {
        // Skip feed filters if it's an explore page
        if (widget.sourceId != null) return true;

        for (var filter
            in context.read<SettingsController>().feedFiltersRegExp) {
          if ((post.title != null && filter.hasMatch(post.title!)) ||
              (post.body != null && filter.hasMatch(post.body!))) {
            return false;
          }
        }

        return true;
      }).toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
    } catch (error, st) {
      print(error);
      print(st);
      _pagingController.error = error;
    }
  }

  void backToTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Durations.long1,
      curve: Curves.easeInOut,
    );
  }

  void refresh() {
    _pagingController.refresh();
  }

  @override
  void didUpdateWidget(covariant FeedScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode ||
        widget.sort != oldWidget.sort ||
        widget.source != oldWidget.source ||
        widget.sourceId != oldWidget.sourceId) {
      _pagingController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (widget.details != null)
            SliverToBoxAdapter(
              child: widget.details,
            ),
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<PostModel>(
              itemBuilder: (context, item, index) {
                final inner = InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostPage(
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
                  child: PostItem(
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
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: inner,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
