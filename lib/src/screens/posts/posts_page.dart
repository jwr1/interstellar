import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/comments.dart' as api_comments;
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/screens/posts/posts_comment.dart';
import 'package:interstellar/src/screens/posts/posts_item.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  const PostPage(
    this.item,
    this.onUpdate, {
    super.key,
  });

  final api_posts.PostItem item;
  final void Function(api_posts.PostItem) onUpdate;

  @override
  State<PostPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<PostPage> {
  api_comments.CommentsSort commentsSort = api_comments.CommentsSort.hot;

  final PagingController<int, api_comments.Comment> _pagingController =
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
      final newPage = await api_comments.fetchPostComments(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        widget.item.postId,
        page: pageKey,
        sort: commentsSort,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.user.username),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostItem(
                widget.item,
                widget.onUpdate,
                onReply: (body) async {
                  var newComment = await api_comments.postComment(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    body,
                    widget.item.postId,
                    api_comments.CommentType.post
                  );
                  var newList = _pagingController.itemList;
                  newList?.insert(0, newComment);
                  setState(() {
                    _pagingController.itemList = newList;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    DropdownButton<api_comments.CommentsSort>(
                      value: commentsSort,
                      onChanged: (newSort) {
                        if (newSort != null) {
                          setState(() {
                            commentsSort = newSort;
                            _pagingController.refresh();
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: api_comments.CommentsSort.hot,
                          child: Text('Hot'),
                        ),
                        DropdownMenuItem(
                          value: api_comments.CommentsSort.top,
                          child: Text('Top'),
                        ),
                        DropdownMenuItem(
                          value: api_comments.CommentsSort.newest,
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: api_comments.CommentsSort.active,
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: api_comments.CommentsSort.oldest,
                          child: Text('Oldest'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PagedSliverList<int, api_comments.Comment>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<api_comments.Comment>(
                itemBuilder: (context, item, index) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: PostComment(item, (newValue) {
                    var newList = _pagingController.itemList;
                    newList![index] = newValue;
                    setState(() {
                      _pagingController.itemList = newList;
                    });
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
