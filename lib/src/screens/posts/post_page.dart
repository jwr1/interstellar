import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/post_comments.dart' as api_comments;
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_item.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  const PostPage(
    this.initData,
    this.onUpdate, {
    super.key,
  });

  final PostModel initData;
  final void Function(PostModel) onUpdate;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  PostModel? _data;

  api_comments.CommentsSort commentsSort = api_comments.CommentsSort.hot;

  final PagingController<int, PostCommentModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _data = widget.initData;

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  void _onUpdate(PostModel newValue) {
    setState(() {
      _data = newValue;
    });
    widget.onUpdate(newValue);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await api_comments.fetchComments(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        _data!.postId,
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
        title: Text(_data?.user.username ?? ''),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: CustomScrollView(
          slivers: [
            if (_data != null)
              SliverToBoxAdapter(
                child: PostItem(
                  _data!,
                  _onUpdate,
                  onReply: whenLoggedIn(context, (body) async {
                    var newComment = await api_comments.postComment(
                      context.read<SettingsController>().httpClient,
                      context.read<SettingsController>().instanceHost,
                      body,
                      _data!.postId,
                    );
                    var newList = _pagingController.itemList;
                    newList?.insert(0, newComment);
                    setState(() {
                      _pagingController.itemList = newList;
                    });
                  }),
                  onEdit: _data!.visibility != 'soft_deleted'
                      ? whenLoggedIn(
                          context,
                          (body) async {
                            final newPost = await api_posts.editPost(
                                context.read<SettingsController>().httpClient,
                                context.read<SettingsController>().instanceHost,
                                _data!.postId,
                                body,
                                _data!.lang,
                                _data!.isAdult);
                            _onUpdate(newPost);
                          },
                          matchesUsername: _data!.user.username,
                        )
                      : null,
                  onDelete: _data!.visibility != 'soft_deleted'
                      ? whenLoggedIn(
                          context,
                          () async {
                            await api_posts.deletePost(
                              context.read<SettingsController>().httpClient,
                              context.read<SettingsController>().instanceHost,
                              _data!.postId,
                            );
                            _onUpdate(_data!.copyWith(
                              body: '_post deleted_',
                              uv: null,
                              dv: null,
                              favourites: null,
                              visibility: 'soft_deleted',
                            ));
                          },
                          matchesUsername: _data!.user.username,
                        )
                      : null,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
            PagedSliverList<int, PostCommentModel>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<PostCommentModel>(
                itemBuilder: (context, item, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: PostComment(item, (newValue) {
                    var newList = _pagingController.itemList;
                    newList![index] = newValue;
                    setState(() {
                      _pagingController.itemList = newList;
                    });
                  },
                  opUserId: widget.initData.user.userId),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
