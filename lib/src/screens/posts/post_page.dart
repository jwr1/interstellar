import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/comment.dart';
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
  late PostModel _data;

  CommentSort commentSort = CommentSort.hot;

  final PagingController<int, PostCommentModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _data = widget.initData;
    commentSort = context.read<SettingsController>().defaultCommentSort;

    _pagingController.addPageRequestListener(_fetchPage);
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
        _data.postId,
        page: pageKey,
        sort: commentSort,
      );

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;
      // Prevent duplicates
      final currentItemIds =
          _pagingController.itemList?.map((e) => e.commentId) ?? [];
      final newItems = newPage.items
          .where((e) => !currentItemIds.contains(e.commentId))
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
    final currentCommentSortOption = commentSortSelect.getOption(commentSort);

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _data.user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              const Text('Comments'),
              const SizedBox(width: 6),
              Icon(currentCommentSortOption.icon, size: 20),
              const SizedBox(width: 2),
              Text(currentCommentSortOption.title),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                final newSort = await commentSortSelect.inquireSelection(
                    context, commentSort);

                if (newSort != null && newSort != commentSort) {
                  setState(() {
                    commentSort = newSort;
                    _pagingController.refresh();
                  });
                }
              },
              icon: const Icon(Icons.sort),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PostItem(
                _data,
                _onUpdate,
                onReply: whenLoggedIn(context, (body) async {
                  var newComment = await api_comments.postComment(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    body,
                    _data.postId,
                  );
                  var newList = _pagingController.itemList;
                  newList?.insert(0, newComment);
                  setState(() {
                    _pagingController.itemList = newList;
                  });
                }),
                onEdit: _data.visibility != 'soft_deleted'
                    ? whenLoggedIn(
                        context,
                        (body) async {
                          final newPost = await api_posts.editPost(
                              context.read<SettingsController>().httpClient,
                              context.read<SettingsController>().instanceHost,
                              _data.postId,
                              body,
                              _data.lang,
                              _data.isAdult);
                          _onUpdate(newPost);
                        },
                        matchesUsername: _data.user.username,
                      )
                    : null,
                onDelete: _data.visibility != 'soft_deleted'
                    ? whenLoggedIn(
                        context,
                        () async {
                          await api_posts.deletePost(
                            context.read<SettingsController>().httpClient,
                            context.read<SettingsController>().instanceHost,
                            _data.postId,
                          );
                          _onUpdate(_data.copyWith(
                            body: '_post deleted_',
                            uv: null,
                            dv: null,
                            favourites: null,
                            visibility: 'soft_deleted',
                          ));
                        },
                        matchesUsername: _data.user.username,
                      )
                    : null,
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
                  }, opUserId: widget.initData.user.userId),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
