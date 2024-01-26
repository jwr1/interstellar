import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
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
  final ContentSource? contentSource;
  final Widget? title;
  final Widget? details;
  final Widget? floatingActionButton;

  const FeedScreen({
    super.key,
    this.contentSource,
    this.title,
    this.details,
    this.floatingActionButton,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

enum FeedMode { entries, posts }

class _FeedScreenState extends State<FeedScreen> {
  FeedMode _feedMode = FeedMode.entries;
  ContentSort _sort = ContentSort.hot;

  @override
  Widget build(BuildContext context) {
    print(widget.contentSource);
    return Wrapper(
      shouldWrap: widget.contentSource == null,
      parentBuilder: (child) => DefaultTabController(length: 4, child: child),
      child: Scaffold(
        appBar: AppBar(
          title: widget.title ??
              Text(context.read<SettingsController>().selectedAccount +
                  (context.read<SettingsController>().isLoggedIn
                      ? ''
                      : ' (Anonymous)')),
          actions: [
            if ((widget.contentSource ?? const ContentAll()).getPostsPath() !=
                null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: FeedMode.entries,
                      label: Text("Threads"),
                    ),
                    ButtonSegment(
                      value: FeedMode.posts,
                      label: Text("Posts"),
                    ),
                  ],
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                  ),
                  selected: <FeedMode>{_feedMode},
                  onSelectionChanged: (Set<FeedMode> newSelection) {
                    setState(() {
                      _feedMode = newSelection.first;
                    });
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                  onPressed: () async {
                    final newContentSort = await contentSortSelect
                        .inquireSelection(context, _sort);

                    if (newContentSort != null && newContentSort != _sort) {
                      setState(() {
                        _sort = newContentSort;
                      });
                    }
                  },
                  icon: const Icon(Icons.sort)),
            )
          ],
          bottom: widget.contentSource == null
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
        body: widget.contentSource != null
            ? FeedScreenBody(
                contentSource: widget.contentSource!,
                contentSort: _sort,
                feedMode: _feedMode,
                details: widget.details,
              )
            : whenLoggedIn(
                context,
                TabBarView(
                  children: [
                    FeedScreenBody(
                      contentSource: const ContentSub(),
                      contentSort: _sort,
                      feedMode: _feedMode,
                      details: widget.details,
                    ),
                    FeedScreenBody(
                      contentSource: const ContentMod(),
                      contentSort: _sort,
                      feedMode: _feedMode,
                      details: widget.details,
                    ),
                    FeedScreenBody(
                      contentSource: const ContentFav(),
                      contentSort: _sort,
                      feedMode: _feedMode,
                      details: widget.details,
                    ),
                    FeedScreenBody(
                      contentSource: const ContentAll(),
                      contentSort: _sort,
                      feedMode: _feedMode,
                      details: widget.details,
                    ),
                  ],
                ),
                otherwise: FeedScreenBody(
                  contentSource: const ContentAll(),
                  contentSort: _sort,
                  feedMode: _feedMode,
                  details: widget.details,
                ),
              ),
        floatingActionButton: widget.floatingActionButton ??
            (widget.contentSource == null
                ? whenLoggedIn(context, const FloatingMenu())
                : null),
      ),
    );
  }

  static const SelectionMenu<ContentSort> contentSortSelect = SelectionMenu(
    'Sort by',
    [
      SelectionMenuItem(
        value: ContentSort.hot,
        title: 'Hot',
        icon: Icons.local_fire_department,
      ),
      SelectionMenuItem(
        value: ContentSort.top,
        title: 'Top',
        icon: Icons.trending_up,
      ),
      SelectionMenuItem(
        value: ContentSort.newest,
        title: 'Newest',
        icon: Icons.auto_awesome_rounded,
      ),
      SelectionMenuItem(
        value: ContentSort.active,
        title: 'Active',
        icon: Icons.rocket_launch,
      ),
      SelectionMenuItem(
        value: ContentSort.commented,
        title: 'Commented',
        icon: Icons.chat,
      ),
      SelectionMenuItem(
        value: ContentSort.oldest,
        title: 'Oldest',
        icon: Icons.access_time_outlined,
      ),
    ],
  );
}

class FeedScreenBody extends StatefulWidget {
  final ContentSource contentSource;
  final ContentSort contentSort;
  final FeedMode feedMode;
  final Widget? details;

  const FeedScreenBody({
    super.key,
    required this.contentSource,
    required this.contentSort,
    required this.feedMode,
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
      dynamic newPage = await (switch (widget.feedMode) {
        FeedMode.entries => api_entries.fetchEntries(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.contentSource,
            page: pageKey,
            sort: widget.contentSort,
          ),
        FeedMode.posts => api_posts.fetchPosts(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.contentSource,
            page: pageKey,
            sort: widget.contentSort,
          ),
      });

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;
      // Prevent duplicates
      var newItems = [];
      switch (widget.feedMode) {
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
                        builder: (context) => switch (widget.feedMode) {
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
                  child: switch (widget.feedMode) {
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
