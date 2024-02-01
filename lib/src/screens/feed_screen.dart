import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/screens/entries/entry_item.dart';
import 'package:interstellar/src/screens/entries/entry_page.dart';
import 'package:interstellar/src/screens/posts/post_item.dart';
import 'package:interstellar/src/screens/posts/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/floating_menu.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  final FeedSource? source;
  final Widget? title;
  final Widget? details;
  final Widget? floatingActionButton;

  const FeedScreen({
    super.key,
    this.source,
    this.title,
    this.details,
    this.floatingActionButton,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

enum FeedMode { entries, posts }

class _FeedScreenState extends State<FeedScreen> {
  FeedMode _mode = FeedMode.entries;
  FeedSort _sort = FeedSort.hot;

  @override
  void initState() {
    super.initState();

    _mode = (widget.source ?? const FeedSourceAll()).getPostsPath() != null
        ? context.read<SettingsController>().defaultFeedMode
        : FeedMode.entries;
    _sort = widget.source == null
        ? _mode == FeedMode.entries
            ? context.read<SettingsController>().defaultEntriesFeedSort
            : context.read<SettingsController>().defaultPostsFeedSort
        : context.read<SettingsController>().defaultExploreFeedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      shouldWrap: widget.source == null,
      parentBuilder: (child) => DefaultTabController(length: 4, child: child),
      child: Scaffold(
        appBar: AppBar(
          title: widget.title ??
              Text(context.read<SettingsController>().selectedAccount +
                  (context.read<SettingsController>().isLoggedIn
                      ? ''
                      : ' (Anonymous)')),
          actions: [
            if ((widget.source ?? const FeedSourceAll()).getPostsPath() != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async {
                    final newMode =
                        await feedModeSelect.inquireSelection(context, _mode);

                    if (newMode != null && newMode != _mode) {
                      setState(() {
                        _mode = newMode;
                        _sort = widget.source == null
                            ? _mode == FeedMode.entries
                                ? context
                                    .read<SettingsController>()
                                    .defaultEntriesFeedSort
                                : context
                                    .read<SettingsController>()
                                    .defaultPostsFeedSort
                            : context
                                .read<SettingsController>()
                                .defaultExploreFeedSort;
                      });
                    }
                  },
                  icon: _mode == FeedMode.entries
                      ? const Icon(Icons.feed)
                      : const Icon(Icons.chat),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async {
                  final newSort =
                      await feedSortSelect.inquireSelection(context, _sort);

                  if (newSort != null && newSort != _sort) {
                    setState(() {
                      _sort = newSort;
                    });
                  }
                },
                icon: const Icon(Icons.sort),
              ),
            ),
          ],
          bottom: widget.source == null
              ? whenLoggedIn(
                  context,
                  const TabBar(tabs: [
                    Tab(
                      text: 'Sub',
                      icon: Icon(Icons.group),
                    ),
                    Tab(
                      text: 'Mod',
                      icon: Icon(Icons.lock),
                    ),
                    Tab(
                      text: 'Fav',
                      icon: Icon(Icons.favorite),
                    ),
                    Tab(
                      text: 'All',
                      icon: Icon(Icons.newspaper),
                    ),
                  ]),
                )
              : null,
        ),
        body: widget.source != null
            ? FeedScreenBody(
                source: widget.source!,
                sort: _sort,
                mode: _mode,
                details: widget.details,
              )
            : whenLoggedIn(
                context,
                TabBarView(
                  children: [
                    FeedScreenBody(
                      source: const FeedSourceSub(),
                      sort: _sort,
                      mode: _mode,
                      details: widget.details,
                    ),
                    FeedScreenBody(
                      source: const FeedSourceMod(),
                      sort: _sort,
                      mode: _mode,
                      details: widget.details,
                    ),
                    FeedScreenBody(
                      source: const FeedSourceFav(),
                      sort: _sort,
                      mode: _mode,
                      details: widget.details,
                    ),
                    FeedScreenBody(
                      source: const FeedSourceAll(),
                      sort: _sort,
                      mode: _mode,
                      details: widget.details,
                    ),
                  ],
                ),
                otherwise: FeedScreenBody(
                  source: const FeedSourceAll(),
                  sort: _sort,
                  mode: _mode,
                  details: widget.details,
                ),
              ),
        floatingActionButton: widget.floatingActionButton ??
            (widget.source == null
                ? whenLoggedIn(context, const FloatingMenu())
                : null),
      ),
    );
  }
}

const SelectionMenu<FeedMode> feedModeSelect = SelectionMenu(
  'Feed Mode',
  [
    SelectionMenuItem(
      value: FeedMode.entries,
      title: 'Threads',
      icon: Icons.feed,
    ),
    SelectionMenuItem(
      value: FeedMode.posts,
      title: 'Posts',
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
  ],
);

class FeedScreenBody extends StatefulWidget {
  final FeedSource source;
  final FeedSort sort;
  final FeedMode mode;
  final Widget? details;

  const FeedScreenBody({
    super.key,
    required this.source,
    required this.sort,
    required this.mode,
    this.details,
  });

  @override
  State<FeedScreenBody> createState() => _FeedScreenBodyState();
}

class _FeedScreenBodyState extends State<FeedScreenBody> {
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      dynamic newPage = await (switch (widget.mode) {
        FeedMode.entries => api_entries.fetchEntries(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.source,
            page: pageKey,
            sort: widget.sort,
          ),
        FeedMode.posts => api_posts.fetchPosts(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.source,
            page: pageKey,
            sort: widget.sort,
          ),
      });

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;
      // Prevent duplicates
      var newItems = [];
      switch (widget.mode) {
        case FeedMode.entries:
          final currentItemIds =
              _pagingController.itemList?.map((e) => e.entryId) ?? [];
          newItems = newPage.items
              .where((e) => !currentItemIds.contains(e.entryId))
              .toList();
          break;
        case FeedMode.posts:
          final currentItemIds =
              _pagingController.itemList?.map((e) => e.postId) ?? [];
          newItems = newPage.items
              .where((e) => !currentItemIds.contains(e.postId))
              .toList();
          break;

        default:
      }

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
  void didUpdateWidget(covariant FeedScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          if (widget.details != null)
            SliverToBoxAdapter(
              child: widget.details,
            ),
          PagedSliverList<int, dynamic>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              itemBuilder: (context, item, index) => Card(
                margin: const EdgeInsets.all(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => switch (widget.mode) {
                          FeedMode.entries => EntryPage(item, (newValue) {
                              var newList = _pagingController.itemList;
                              newList![index] = newValue;
                              setState(() {
                                _pagingController.itemList = newList;
                              });
                            }),
                          FeedMode.posts => PostPage(item, (newValue) {
                              var newList = _pagingController.itemList;
                              newList![index] = newValue;
                              setState(() {
                                _pagingController.itemList = newList;
                              });
                            })
                        },
                      ),
                    );
                  },
                  child: switch (widget.mode) {
                    FeedMode.entries => EntryItem(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                        isPreview: true,
                      ),
                    FeedMode.posts => PostItem(
                        item,
                        (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                      )
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
