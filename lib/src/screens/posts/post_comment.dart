import 'package:flutter/material.dart';
import 'package:interstellar/src/api/post_comments.dart' as api_comments;
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_comment_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item.dart';
import 'package:provider/provider.dart';

class PostComment extends StatefulWidget {
  const PostComment(this.comment, this.onUpdate, {super.key});

  final PostCommentModel comment;
  final void Function(PostCommentModel) onUpdate;

  @override
  State<PostComment> createState() => _EntryCommentState();
}

class _EntryCommentState extends State<PostComment> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(top: 8),
          child: ContentItem(
            body: widget.comment.body ?? '_comment deleted_',
            createdAt: widget.comment.createdAt,
            user: widget.comment.user.username,
            userIcon: widget.comment.user.avatar?.storageUrl,
            userIdOnClick: widget.comment.user.userId,
            boosts: widget.comment.uv,
            isBoosted: widget.comment.userVote == 1,
            onBoost: whenLoggedIn(context, () async {
              var newValue = await api_comments.putVote(
                context.read<SettingsController>().httpClient,
                context.read<SettingsController>().instanceHost,
                widget.comment.commentId,
                1,
              );
              widget.onUpdate(newValue.copyWith(
                childCount: widget.comment.childCount,
                children: widget.comment.children,
              ));
            }),
            upVotes: widget.comment.favourites,
            onUpVote: whenLoggedIn(context, () async {
              var newValue = await api_comments.putFavorite(
                context.read<SettingsController>().httpClient,
                context.read<SettingsController>().instanceHost,
                widget.comment.commentId,
              );
              widget.onUpdate(newValue.copyWith(
                childCount: widget.comment.childCount,
                children: widget.comment.children,
              ));
            }),
            isUpVoted: widget.comment.isFavourited == true,
            downVotes: widget.comment.dv,
            isDownVoted: widget.comment.userVote == -1,
            onDownVote: whenLoggedIn(context, () async {
              var newValue = await api_comments.putVote(
                context.read<SettingsController>().httpClient,
                context.read<SettingsController>().instanceHost,
                widget.comment.commentId,
                -1,
              );
              widget.onUpdate(newValue.copyWith(
                childCount: widget.comment.childCount,
                children: widget.comment.children,
              ));
            }),
            onReply: whenLoggedIn(context, (body) async {
              var newSubComment = await api_comments.postComment(
                context.read<SettingsController>().httpClient,
                context.read<SettingsController>().instanceHost,
                body,
                widget.comment.postId,
                parentCommentId: widget.comment.commentId,
              );

              widget.onUpdate(widget.comment.copyWith(
                childCount: widget.comment.childCount + 1,
                children: [newSubComment, ...widget.comment.children!],
              ));
            }),
            onEdit: widget.comment.visibility != 'soft_deleted'
                ? whenLoggedIn(context, (body) async {
                    var newValue = await api_comments.editComment(
                        context.read<SettingsController>().httpClient,
                        context.read<SettingsController>().instanceHost,
                        widget.comment.commentId,
                        body,
                        widget.comment.lang,
                        widget.comment.isAdult);
                    widget.onUpdate(newValue.copyWith(
                      childCount: widget.comment.childCount,
                      children: widget.comment.children,
                    ));
                  })
                : null,
            onDelete: widget.comment.visibility != 'soft_deleted'
                ? whenLoggedIn(context, () async {
                    await api_comments.deleteComment(
                      context.read<SettingsController>().httpClient,
                      context.read<SettingsController>().instanceHost,
                      widget.comment.commentId,
                    );
                    widget.onUpdate(widget.comment.copyWith(
                      body: '_comment deleted_',
                      uv: null,
                      dv: null,
                      favourites: null,
                      visibility: 'soft_deleted',
                    ));
                  })
                : null,
            isCollapsed: _isCollapsed,
            onCollapse: widget.comment.childCount > 0
                ? () => setState(() {
                      _isCollapsed = !_isCollapsed;
                    })
                : null,
          ),
        ),
        if (widget.comment.childCount > 0 &&
            !_isCollapsed &&
            (widget.comment.children?.isEmpty ?? false))
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PostCommentScreen(widget.comment.commentId),
              ),
            ),
            child: Text(
                'Open ${widget.comment.childCount} reply${widget.comment.childCount == 1 ? '' : 's'}'),
          ),
        if (widget.comment.childCount > 0 && !_isCollapsed)
          Container(
            margin: const EdgeInsets.only(left: 1),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: widget.comment.children!
                  .asMap()
                  .entries
                  .map((item) => PostComment(item.value, (newValue) {
                        var newChildren = [...widget.comment.children!];
                        newChildren[item.key] = newValue;
                        widget.onUpdate(widget.comment.copyWith(
                          childCount: widget.comment.childCount + 1,
                          children: newChildren,
                        ));
                      }))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
