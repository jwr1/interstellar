import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
import 'package:interstellar/src/screens/feed/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/floating_menu.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  final FeedSource? source;
  final String? title;
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

class _FeedScreenState extends State<FeedScreen> {
  PostType _mode = PostType.thread;
  FeedSort _sort = FeedSort.hot;

  @override
  void initState() {
    super.initState();

    _mode = (widget.source ?? const FeedSourceAll()).getPostsPath() != null
        ? context.read<SettingsController>().defaultFeedType
        : PostType.thread;
    _sort = widget.source == null
        ? _mode == PostType.thread
            ? context.read<SettingsController>().defaultEntriesFeedSort
            : context.read<SettingsController>().defaultPostsFeedSort
        : context.read<SettingsController>().defaultExploreFeedSort;
  }

  @override
  Widget build(BuildContext context) {
    final currentFeedModeOption = feedTypeSelect.getOption(_mode);
    final currentFeedSortOption = feedSortSelect.getOption(_sort);

    return Wrapper(
      shouldWrap: widget.source == null,
      parentBuilder: (child) => DefaultTabController(length: 4, child: child),
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.title ??
                  context.read<SettingsController>().selectedAccount +
                      (context.read<SettingsController>().isLoggedIn
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
          actions: [
            if ((widget.source ?? const FeedSourceAll()).getPostsPath() != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async {
                    final newMode =
                        await feedTypeSelect.inquireSelection(context, _mode);

                    if (newMode != null && newMode != _mode) {
                      setState(() {
                        _mode = newMode;
                        _sort = widget.source == null
                            ? _mode == PostType.thread
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
                  icon: _mode == PostType.thread
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
  ],
);

class FeedScreenBody extends StatefulWidget {
  final FeedSource source;
  final FeedSort sort;
  final PostType mode;
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
  final PagingController<String, PostModel> _pagingController =
      PagingController(firstPageKey: '1');

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      PostListModel newPage = await (switch (widget.mode) {
        PostType.thread =>
          context.read<SettingsController>().kbinAPI.entries.list(
                widget.source,
                page: int.parse(pageKey),
                sort: widget.sort,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              ),
        PostType.microblog =>
          context.read<SettingsController>().kbinAPI.posts.list(
                widget.source,
                page: int.parse(pageKey),
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
          .toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
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
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<PostModel>(
              itemBuilder: (context, item, index) => Card(
                margin: const EdgeInsets.all(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostPage(item, (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        }),
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
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
