import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/posts/post_item.dart';
import 'package:interstellar/src/screens/posts/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class PostsListView extends StatefulWidget {
  const PostsListView({
    super.key,
    this.contentSource = const ContentAll(),
    this.details,
  });

  final ContentSource contentSource;
  final Widget? details;

  @override
  State<PostsListView> createState() => _PostsListViewState();
}

class _PostsListViewState extends State<PostsListView> {
  ContentSort sort = ContentSort.hot;

  final PagingController<int, PostModel> _pagingController =
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
      final newPage = await api_posts.fetchPosts(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        widget.contentSource,
        page: pageKey,
        sort: sort,
      );

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;
      // Prevent duplicates
      final currentItemIds =
          _pagingController.itemList?.map((e) => e.postId) ?? [];
      final newItems = newPage.items
          .where((e) => !currentItemIds.contains(e.postId))
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
          if (widget.details != null)
            SliverToBoxAdapter(
              child: widget.details,
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  DropdownButton<ContentSort>(
                    value: sort,
                    onChanged: (newSort) {
                      if (newSort != null) {
                        setState(() {
                          sort = newSort;
                          _pagingController.refresh();
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ContentSort.hot,
                        child: Text('Hot'),
                      ),
                      DropdownMenuItem(
                        value: ContentSort.top,
                        child: Text('Top'),
                      ),
                      DropdownMenuItem(
                        value: ContentSort.newest,
                        child: Text('Newest'),
                      ),
                      DropdownMenuItem(
                        value: ContentSort.active,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: ContentSort.commented,
                        child: Text('Commented'),
                      ),
                      DropdownMenuItem(
                        value: ContentSort.oldest,
                        child: Text('Oldest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PagedSliverList<int, PostModel>(
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
                    isPreview: true,
                  ),
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
