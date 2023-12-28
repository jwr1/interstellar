import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/screens/posts/posts_item.dart';
import 'package:interstellar/src/screens/posts/posts_page.dart';
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
  api_posts.PostsSort sort = api_posts.PostsSort.hot;

  final PagingController<int, api_posts.PostItem> _pagingController =
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

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;

      if (isLastPage) {
        _pagingController.appendLastPage(newPage.items);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newPage.items, nextPageKey);
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  DropdownButton<api_posts.PostsSort>(
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
                        value: api_posts.PostsSort.hot,
                        child: Text('Hot'),
                      ),
                      DropdownMenuItem(
                        value: api_posts.PostsSort.top,
                        child: Text('Top'),
                      ),
                      DropdownMenuItem(
                        value: api_posts.PostsSort.newest,
                        child: Text('Newest'),
                      ),
                      DropdownMenuItem(
                        value: api_posts.PostsSort.active,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: api_posts.PostsSort.commented,
                        child: Text('Commented'),
                      ),
                      DropdownMenuItem(
                        value: api_posts.PostsSort.oldest,
                        child: Text('Oldest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PagedSliverList<int, api_posts.PostItem>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<api_posts.PostItem>(
              itemBuilder: (context, item, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
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
