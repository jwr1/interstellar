import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/feed/post_comment.dart';
import 'package:interstellar/src/screens/feed/post_item.dart';
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

  final PagingController<String, CommentModel> _pagingController =
      PagingController(firstPageKey: '1');

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

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage =
          await context.read<SettingsController>().kbinAPI.comments.list(
                _data.type,
                _data.id,
                page: int.parse(pageKey),
                sort: commentSort,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
              );

      // Check BuildContext
      if (!mounted) return;

      // Prevent duplicates
      final currentItemIds = _pagingController.itemList?.map((e) => e.id) ?? [];
      final newItems =
          newPage.items.where((e) => !currentItemIds.contains(e.id)).toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
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
            _data.user.name,
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
                  var newComment = await context
                      .read<SettingsController>()
                      .kbinAPI
                      .comments
                      .create(
                        _data.type,
                        _data.id,
                        body,
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
                          final newPost = await switch (_data.type) {
                            PostType.thread => context
                                .read<SettingsController>()
                                .kbinAPI
                                .entries
                                .edit(
                                  _data.id,
                                  _data.title!,
                                  _data.isOc!,
                                  body,
                                  _data.lang,
                                  _data.isAdult,
                                ),
                            PostType.microblog => context
                                .read<SettingsController>()
                                .kbinAPI
                                .posts
                                .edit(
                                  _data.id,
                                  body,
                                  _data.lang,
                                  _data.isAdult,
                                ),
                          };
                          _onUpdate(newPost);
                        },
                        matchesUsername: _data.user.name,
                      )
                    : null,
                onDelete: _data.visibility != 'soft_deleted'
                    ? whenLoggedIn(
                        context,
                        () async {
                          await switch (_data.type) {
                            PostType.thread => context
                                .read<SettingsController>()
                                .kbinAPI
                                .entries
                                .delete(_data.id),
                            PostType.microblog => context
                                .read<SettingsController>()
                                .kbinAPI
                                .posts
                                .delete(_data.id),
                          };
                          _onUpdate(_data.copyWith(
                            body: '_post deleted_',
                            upvotes: null,
                            downvotes: null,
                            boosts: null,
                            visibility: 'soft_deleted',
                          ));
                        },
                        matchesUsername: _data.user.name,
                      )
                    : null,
              ),
            ),
            PagedSliverList(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<CommentModel>(
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
                  }, opUserId: widget.initData.user.id),
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
