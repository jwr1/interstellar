import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/feed/create_screen.dart';
import 'package:interstellar/src/screens/feed/nav_drawer.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
import 'package:interstellar/src/screens/feed/post_item_compact.dart';
import 'package:interstellar/src/screens/feed/post_page.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/actions.dart';
import 'package:interstellar/src/widgets/error_page.dart';
import 'package:interstellar/src/widgets/floating_menu.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:material_symbols_icons/symbols.dart';
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

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin<FeedScreen> {
  final _fabKey = GlobalKey<FloatingMenuState>();
  final List<GlobalKey<_FeedScreenBodyState>> _feedKeyList = [];
  late FeedSource _filter;
  late PostType _mode;
  FeedSort? _sort;

  @override
  bool get wantKeepAlive => true;

  _getFeedKey(int index) {
    while (index >= _feedKeyList.length) {
      _feedKeyList.add(GlobalKey());
    }
    return _feedKeyList[index];
  }

  FeedSort _defaultSortFromMode(PostType mode) => widget.source == null
      ? mode == PostType.thread
          ? context.read<AppController>().profile.feedDefaultThreadsSort
          : context.read<AppController>().profile.feedDefaultMicroblogSort
      : context.read<AppController>().profile.feedDefaultExploreSort;

  @override
  void initState() {
    super.initState();

    _filter = whenLoggedIn(
            context, context.read<AppController>().profile.feedDefaultFilter) ??
        FeedSource.all;
    _mode = context.read<AppController>().serverSoftware != ServerSoftware.lemmy
        ? context.read<AppController>().profile.feedDefaultType
        : PostType.thread;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sort = _sort ?? _defaultSortFromMode(_mode);

    final currentFeedModeOption = feedTypeSelect(context).getOption(_mode);
    final currentFeedSortOption = feedSortSelect(context).getOption(sort);

    final actions = [
      feedActionCreateNew(context).withProps(
        context.watch<AppController>().isLoggedIn
            ? context.watch<AppController>().profile.feedActionCreateNew
            : ActionLocation.hide,
        () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CreateScreen(initMagazine: widget.createPostMagazine),
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
                context.watch<AppController>().profile.feedActionSetFilter.name,
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
          context.watch<AppController>().profile.feedActionSetSort.name,
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
                context.watch<AppController>().serverSoftware ==
                    ServerSoftware.lemmy
            ? ActionLocation.hide
            : parseEnum(
                ActionLocation.values,
                ActionLocation.hide,
                context.watch<AppController>().profile.feedActionSetType.name,
              ),
        () async {
          final newMode =
              await feedTypeSelect(context).askSelection(context, _mode);

          if (newMode != null && newMode != _mode) {
            setState(() {
              _mode = newMode;
            });
          }
        },
      ),
      feedActionRefresh(context).withProps(
        context.watch<AppController>().profile.feedActionRefresh,
        () {
          for (var key in _feedKeyList) {
            key.currentState?.refresh();
          }
        },
      ),
      feedActionBackToTop(context).withProps(
        context.watch<AppController>().profile.feedActionBackToTop,
        () {
          for (var key in _feedKeyList) {
            key.currentState?.backToTop();
          }
        },
      ),
      feedActionExpandFab(context).withProps(
        context.watch<AppController>().profile.feedActionExpandFab,
        () {
          _fabKey.currentState?.toggle();
        },
      ),
    ];

    final tabsAction = [
      if (context.watch<AppController>().profile.feedActionSetFilter ==
              ActionLocationWithTabs.tabs &&
          widget.source == null &&
          context.watch<AppController>().isLoggedIn)
        actions.firstWhere(
            (action) => action.name == feedActionSetFilter(context).name),
      if (context.watch<AppController>().profile.feedActionSetType ==
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
                    context.watch<AppController>().profile.feedDefaultFilter)
                .key,
          String name when name == feedActionSetType(context).name =>
            feedTypeSelect(context)
                .options
                .asMap()
                .entries
                .firstWhere((entry) =>
                    entry.value.value ==
                    (context.watch<AppController>().serverSoftware !=
                            ServerSoftware.lemmy
                        ? context.watch<AppController>().profile.feedDefaultType
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
        child: DefaultTabControllerListener(
          onTabSelected: tabsAction?.name == feedActionSetType(context).name
              ? (newIndex) {
                  setState(() {
                    switch (newIndex) {
                      case 0:
                        _mode = PostType.thread;
                        break;
                      case 1:
                        _mode = PostType.microblog;
                        break;
                      default:
                    }
                  });
                }
              : null,
          child: child,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.title ??
                  context.watch<AppController>().selectedAccount +
                      (context.watch<AppController>().isLoggedIn
                          ? ''
                          : ' (${l(context).guest})'),
              softWrap: false,
              overflow: TextOverflow.fade,
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
                sort: sort,
                mode: _mode,
                details: widget.details,
              )
            : TabBarView(
                physics: appTabViewPhysics(context),
                children: switch (tabsAction.name) {
                  String name when name == feedActionSetFilter(context).name =>
                    [
                      FeedScreenBody(
                        key: _getFeedKey(0),
                        source: FeedSource.subscribed,
                        sort: sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(1),
                        source: FeedSource.moderated,
                        sort: sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(2),
                        source: FeedSource.favorited,
                        sort: sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(3),
                        source: FeedSource.all,
                        sort: sort,
                        mode: _mode,
                        details: widget.details,
                      ),
                    ],
                  String name when name == feedActionSetType(context).name => [
                      FeedScreenBody(
                        key: _getFeedKey(0),
                        source: widget.source ?? _filter,
                        sourceId: widget.sourceId,
                        sort: _sort ?? _defaultSortFromMode(PostType.thread),
                        mode: PostType.thread,
                        details: widget.details,
                      ),
                      FeedScreenBody(
                        key: _getFeedKey(1),
                        source: widget.source ?? _filter,
                        sourceId: widget.sourceId,
                        sort: _sort ?? _defaultSortFromMode(PostType.microblog),
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
          icon: Symbols.feed_rounded,
        ),
        SelectionMenuItem(
          value: PostType.microblog,
          title: l(context).microblog,
          icon: Symbols.chat_rounded,
        ),
      ],
    );

SelectionMenu<FeedSort> feedSortSelect(BuildContext context) => SelectionMenu(
      l(context).sort,
      [
        SelectionMenuItem(
          value: FeedSort.hot,
          title: l(context).sort_hot,
          icon: Symbols.local_fire_department_rounded,
        ),
        SelectionMenuItem(
          value: FeedSort.top,
          title: l(context).sort_top,
          icon: Symbols.trending_up_rounded,
        ),
        SelectionMenuItem(
          value: FeedSort.newest,
          title: l(context).sort_newest,
          icon: Symbols.nest_eco_leaf_rounded,
        ),
        SelectionMenuItem(
          value: FeedSort.active,
          title: l(context).sort_active,
          icon: Symbols.rocket_launch_rounded,
        ),
        SelectionMenuItem(
          value: FeedSort.commented,
          title: l(context).sort_commented,
          icon: Symbols.chat_rounded,
        ),
        SelectionMenuItem(
          value: FeedSort.oldest,
          title: l(context).sort_oldest,
          icon: Symbols.access_time_rounded,
        ),

        //lemmy specific
        SelectionMenuItem(
          value: FeedSort.newComments,
          title: l(context).sort_newComments,
          icon: Symbols.mark_chat_unread_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.controversial,
          title: l(context).sort_controversial,
          icon: Symbols.thumbs_up_down_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.scaled,
          title: l(context).sort_scaled,
          icon: Symbols.scale_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topDay,
          title: l(context).sort_topDay,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topWeek,
          title: l(context).sort_topWeek,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topMonth,
          title: l(context).sort_topMonth,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topYear,
          title: l(context).sort_topYear,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topHour,
          title: l(context).sort_topHour,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topSixHour,
          title: l(context).sort_topSixHour,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topTwelveHour,
          title: l(context).sort_topTwelveHour,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topThreeMonths,
          title: l(context).sort_topThreeMonths,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topSixMonths,
          title: l(context).sort_topSixMonths,
          icon: Symbols.trending_up_rounded,
          validSoftware: ServerSoftware.lemmy,
        ),
        SelectionMenuItem(
          value: FeedSort.topNineMonths,
          title: l(context).sort_topNineMonths,
          icon: Symbols.trending_up_rounded,
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
          icon: Symbols.group_rounded,
        ),
        SelectionMenuItem(
          value: FeedSource.moderated,
          title: l(context).filter_moderated,
          icon: Symbols.lock_rounded,
        ),
        SelectionMenuItem(
          value: FeedSource.favorited,
          title: l(context).filter_favorited,
          icon: Symbols.favorite_rounded,
        ),
        SelectionMenuItem(
          value: FeedSource.all,
          title: l(context).filter_all,
          icon: Symbols.newspaper_rounded,
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

class _FeedScreenBodyState extends State<FeedScreenBody>  with AutomaticKeepAliveClientMixin<FeedScreenBody> {
  final _pagingController =
      PagingController<String, PostModel>(firstPageKey: '');
  final _scrollController = ScrollController();

  // Map of postId to FilterList names for posts that match lists that are marked as warnings.
  // If a post matches any FilterList that is not shown with warning, then the post is not shown at all.
  final Map<int, Set<String>> _filterListWarnings = {};

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _fetchPage(String pageKey) async {
    if (pageKey.isEmpty) _filterListWarnings.clear();

    try {
      PostListModel newPage = await (switch (widget.mode) {
        PostType.thread => context.read<AppController>().api.threads.list(
              widget.source,
              sourceId: widget.sourceId,
              page: nullIfEmpty(pageKey),
              sort: widget.sort,
              usePreferredLangs: whenLoggedIn(
                  context,
                  context
                      .read<AppController>()
                      .profile
                      .useAccountLanguageFilter),
              langs: context
                  .read<AppController>()
                  .profile
                  .customLanguageFilter
                  .toList(),
            ),
        PostType.microblog => context.read<AppController>().api.microblogs.list(
              widget.source,
              sourceId: widget.sourceId,
              page: nullIfEmpty(pageKey),
              sort: widget.sort,
              usePreferredLangs: whenLoggedIn(
                  context,
                  context
                      .read<AppController>()
                      .profile
                      .useAccountLanguageFilter),
              langs: context
                  .read<AppController>()
                  .profile
                  .customLanguageFilter
                  .toList(),
            ),
      });

      // Check BuildContext
      if (!mounted) return;

      // Prevent duplicates
      List<PostModel> newItems = [];
      final currentItemIds =
          _pagingController.itemList?.map((post) => post.id) ?? [];
      final filterListActivations =
          context.read<AppController>().profile.filterLists;
      newItems = newPage.items
          .where((post) => !currentItemIds.contains(post.id))
          .where((post) {
        // Skip feed filters if it's an explore page
        if (widget.sourceId != null) return true;

        for (var filterListEntry
            in context.read<AppController>().filterLists.entries) {
          if (filterListActivations[filterListEntry.key] == true) {
            final filterList = filterListEntry.value;

            if ((post.title != null && filterList.hasMatch(post.title!)) ||
                (post.body != null && filterList.hasMatch(post.body!))) {
              if (filterList.showWithWarning) {
                if (!_filterListWarnings.containsKey(post.id)) {
                  _filterListWarnings[post.id] = {};
                }

                _filterListWarnings[post.id]!.add(filterListEntry.key);
              } else {
                return false;
              }
            }
          }
        }

        return true;
      }).toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
    } catch (error) {
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
    super.build(context);
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
              firstPageErrorIndicatorBuilder: (context) =>
                  FirstPageErrorIndicator(
                error: _pagingController.error,
                onTryAgain: _pagingController.retryLastFailedRequest,
              ),
              newPageErrorIndicatorBuilder: (context) => NewPageErrorIndicator(
                error: _pagingController.error,
                onTryAgain: _pagingController.retryLastFailedRequest,
              ),
              itemBuilder: (context, item, index) {
                void onPostTap() {
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
                }

                if (context.watch<AppController>().profile.compactMode) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onPostTap,
                        child: PostItemCompact(
                          item,
                          filterListWarnings: _filterListWarnings[item.id],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  );
                } else {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onPostTap,
                      child: PostItem(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        isPreview: true,
                        filterListWarnings: _filterListWarnings[item.id],
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
