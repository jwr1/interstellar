import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/comment.dart';
import 'package:interstellar/src/models/entry.dart';
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_item.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class EntryPage extends StatefulWidget {
  const EntryPage(
    this.initData,
    this.onUpdate, {
    super.key,
  });

  final EntryModel initData;
  final void Function(EntryModel) onUpdate;

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late EntryModel _data;

  CommentSort commentSort = CommentSort.hot;

  final PagingController<int, EntryCommentModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _data = widget.initData;
    commentSort = context.read<SettingsController>().defaultCommentSort;

    _pagingController.addPageRequestListener(_fetchPage);
  }

  void _onUpdate(EntryModel newValue) {
    setState(() {
      _data = newValue;
    });
    widget.onUpdate(newValue);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage =
          await context.read<SettingsController>().kbinAPI.entryComments.list(
                _data.entryId,
                page: pageKey,
                sort: commentSort,
                usePreferredLangs: whenLoggedIn(context,
                    context.read<SettingsController>().useAccountLangFilter),
                langs: context.read<SettingsController>().langFilter.toList(),
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
            _data.title,
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
              child: EntryItem(
                _data,
                _onUpdate,
                onReply: whenLoggedIn(context, (body) async {
                  var newComment = await context
                      .read<SettingsController>()
                      .kbinAPI
                      .entryComments
                      .create(body, _data.entryId);
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
                          final newEntry = await context
                              .read<SettingsController>()
                              .kbinAPI
                              .entries
                              .putEdit(
                                _data.entryId,
                                _data.title,
                                _data.isOc,
                                body,
                                _data.lang,
                                _data.isAdult,
                              );
                          _onUpdate(newEntry);
                        },
                        matchesUsername: _data.user.username,
                      )
                    : null,
                onDelete: _data.visibility != 'soft_deleted'
                    ? whenLoggedIn(
                        context,
                        () async {
                          await context
                              .read<SettingsController>()
                              .kbinAPI
                              .entries
                              .delete(_data.entryId);
                          _onUpdate(_data.copyWith(
                            body: '_thread deleted_',
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
            PagedSliverList<int, EntryCommentModel>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<EntryCommentModel>(
                itemBuilder: (context, item, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: EntryComment(item, (newValue) {
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
