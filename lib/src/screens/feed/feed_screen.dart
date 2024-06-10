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

    _filter = whenLoggedIn(context, FeedSource.subscribed) ?? FeedSource.all;
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
    final currentFeedModeOption = feedTypeSelect.getOption(_mode);
    final currentFeedSortOption = feedSortSelect.getOption(_sort);

    final actions = [
      feedActionCreatePost.withProps(
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
      feedActionSetFilter.withProps(
        whenLoggedIn(context, widget.source != null) ?? true
            ? ActionLocation.hide
            : parseEnum(
                ActionLocation.values,
                ActionLocation.hide,
                context.watch<SettingsController>().feedActionSetFilter.name,
              ),
        () async {
          final newFilter =
              await feedFilterSelect.askSelection(context, _filter);

          if (newFilter != null && newFilter != _filter) {
            setState(() {
              _filter = newFilter;
            });
          }
        },
      ),
      feedActionSetSort.withProps(
        parseEnum(
          ActionLocation.values,
          ActionLocation.hide,
          context.watch<SettingsController>().feedActionSetSort.name,
        ),
        () async {
          final newSort = await feedSortSelect.askSelection(context, _sort);

          if (newSort != null && newSort != _sort) {
            setState(() {
              _sort = newSort;
            });
          }
        },
      ),
      feedActionSetType.withProps(
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
          final newMode = await feedTypeSelect.askSelection(context, _mode);

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
      feedActionRefresh.withProps(
        context.watch<SettingsController>().feedActionRefresh,
        () {
          for (var key in _feedKeyList) {
            key.currentState?.refresh();
          }
        },
      ),
      feedActionBackToTop.withProps(
        context.watch<SettingsController>().feedActionBackToTop,
        () {
          for (var key in _feedKeyList) {
            key.currentState?.backToTop();
          }
        },
      ),
      feedActionExpandFab.withProps(
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
        actions.firstWhere((action) => action.name == feedActionSetFilter.name),
      if (context.watch<SettingsController>().feedActionSetType ==
          ActionLocationWithTabs.tabs)
        actions.firstWhere((action) => action.name == feedActionSetType.name),
    ].firstOrNull;

    return Wrapper(
      shouldWrap: tabsAction != null,
      parentBuilder: (child) => DefaultTabController(
        initialIndex: switch (tabsAction?.name) {
          String name when name == feedActionSetFilter.name => 0,
          String name when name == feedActionSetType.name => feedTypeSelect
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
          String name when name == feedActionSetFilter.name => 4,
          String name when name == feedActionSetType.name =>
            feedTypeSelect.options.length,
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
                          : ' (Guest)'),
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
                    String name when name == feedActionSetFilter.name => [
                        const Tab(
                          text: 'Sub',
                          icon: Icon(Icons.group),
                        ),
                        const Tab(
                          text: 'Mod',
                          icon: Icon(Icons.lock),
                        ),
                        const Tab(
                          text: 'Fav',
                          icon: Icon(Icons.favorite),
                        ),
                        const Tab(
                          text: 'All',
                          icon: Icon(Icons.newspaper),
                        ),
                      ],
                    String name when name == feedActionSetType.name =>
                      feedTypeSelect.options
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
                  String name when name == feedActionSetFilter.name => [
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
                  String name when name == feedActionSetType.name => [
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

const SelectionMenu<PostType> feedTypeSelect = SelectionMenu(
  'Feed Type',
  [
    SelectionMenuItem(
      value: PostType.thread,
      title: 'Threads',
      icon: Icons.feed,
    ),
    SelectionMenuItem(
      value: PostType.microblog,
      title: 'Microblog',
      icon: Icons.chat,
    ),
  ],
);

const SelectionMenu<FeedSort> feedSortSelect = SelectionMenu(
  'Sort by',
  [
    SelectionMenuItem(
      value: FeedSort.hot,
      title: 'Hot',
      icon: Icons.local_fire_department,
    ),
    SelectionMenuItem(
      value: FeedSort.top,
      title: 'Top',
      icon: Icons.trending_up,
    ),
    SelectionMenuItem(
      value: FeedSort.newest,
      title: 'Newest',
      icon: Icons.auto_awesome_rounded,
    ),
    SelectionMenuItem(
      value: FeedSort.active,
      title: 'Active',
      icon: Icons.rocket_launch,
    ),
    SelectionMenuItem(
      value: FeedSort.commented,
      title: 'Commented',
      icon: Icons.chat,
    ),
    SelectionMenuItem(
      value: FeedSort.oldest,
      title: 'Oldest',
      icon: Icons.access_time_outlined,
    ),

    //lemmy specific
    SelectionMenuItem(
      value: FeedSort.newComments,
      title: 'NewComments',
      icon: Icons.mark_chat_unread,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.controversial,
      title: 'Controversial',
      icon: Icons.thumbs_up_down,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.scaled,
      title: 'Scaled',
      icon: Icons.scale,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topDay,
      title: 'TopDay',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topWeek,
      title: 'TopWeek',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topMonth,
      title: 'TopMonth',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topYear,
      title: 'TopYear',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topHour,
      title: 'TopHour',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topSixHour,
      title: 'TopSixHour',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topTwelveHour,
      title: 'TopTwelveHour',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topThreeMonths,
      title: 'TopThreeMonths',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topSixMonths,
      title: 'TopSixMonths',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
    SelectionMenuItem(
      value: FeedSort.topNineMonths,
      title: 'TopNineMonths',
      icon: Icons.trending_up,
      validSoftware: ServerSoftware.lemmy,
    ),
  ],
);

const SelectionMenu<FeedSource> feedFilterSelect = SelectionMenu(
  'Filter by',
  [
    SelectionMenuItem(
      value: FeedSource.subscribed,
      title: 'Subscribed',
      icon: Icons.group,
    ),
    SelectionMenuItem(
      value: FeedSource.moderated,
      title: 'Moderated',
      icon: Icons.lock,
    ),
    SelectionMenuItem(
      value: FeedSource.favorited,
      title: 'Favorited',
      icon: Icons.favorite,
    ),
    SelectionMenuItem(
      value: FeedSource.all,
      title: 'All',
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
