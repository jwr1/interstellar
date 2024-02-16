import 'package:flutter/material.dart';
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_comment_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class PostComment extends StatefulWidget {
  const PostComment(
    this.comment,
    this.onUpdate, {
    this.opUserId,
    this.onClick,
    super.key,
  });

  final PostCommentModel comment;
  final void Function(PostCommentModel) onUpdate;
  final int? opUserId;
  final void Function()? onClick;

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
          child: Wrapper(
            shouldWrap: widget.onClick != null,
            parentBuilder: (child) =>
                InkWell(onTap: widget.onClick, child: child),
            child: ContentItem(
              originInstance:
                  getNameHost(context, widget.comment.user.username),
              body: widget.comment.body ?? '_comment deleted_',
              createdAt: widget.comment.createdAt,
              user: widget.comment.user.username,
              userIcon: widget.comment.user.avatar?.storageUrl,
              userIdOnClick: widget.comment.user.userId,
              opUserId: widget.opUserId,
              boosts: widget.comment.uv,
              isBoosted: widget.comment.userVote == 1,
              onBoost: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .postComments
                    .putVote(widget.comment.commentId, 1);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              upVotes: widget.comment.favourites,
              onUpVote: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .postComments
                    .putFavorite(widget.comment.commentId);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              isUpVoted: widget.comment.isFavourited == true,
              downVotes: widget.comment.dv,
              isDownVoted: widget.comment.userVote == -1,
              onDownVote: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .postComments
                    .putVote(widget.comment.commentId, -1);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              onReply: whenLoggedIn(context, (body) async {
                var newSubComment = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .postComments
                    .create(
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
                      var newValue = await context
                          .read<SettingsController>()
                          .kbinAPI
                          .postComments
                          .edit(
                            widget.comment.commentId,
                            body,
                            widget.comment.lang,
                            widget.comment.isAdult,
                          );
                      widget.onUpdate(newValue.copyWith(
                        childCount: widget.comment.childCount,
                        children: widget.comment.children,
                      ));
                    }, matchesUsername: widget.comment.user.username)
                  : null,
              onDelete: widget.comment.visibility != 'soft_deleted'
                  ? whenLoggedIn(context, () async {
                      await context
                          .read<SettingsController>()
                          .kbinAPI
                          .postComments
                          .delete(widget.comment.commentId);
                      widget.onUpdate(widget.comment.copyWith(
                        body: '_comment deleted_',
                        uv: null,
                        dv: null,
                        favourites: null,
                        visibility: 'soft_deleted',
                      ));
                    }, matchesUsername: widget.comment.user.username)
                  : null,
              isCollapsed: _isCollapsed,
              onCollapse: widget.comment.childCount > 0
                  ? () => setState(() {
                        _isCollapsed = !_isCollapsed;
                      })
                  : null,
              openLinkUri: Uri.https(
                context.read<SettingsController>().instanceHost,
                '/m/${widget.comment.magazine.name}/p/${widget.comment.postId}/-/reply/${widget.comment.commentId}',
              ),
            ),
          ),
        ),
        if (widget.comment.childCount > 0 &&
            !_isCollapsed &&
            (widget.comment.children?.isEmpty ?? false))
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostCommentScreen(
                    widget.comment.commentId,
                    opUserId: widget.opUserId),
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
                  .map((item) => PostComment(
                        item.value,
                        (newValue) {
                          var newChildren = [...widget.comment.children!];
                          newChildren[item.key] = newValue;
                          widget.onUpdate(widget.comment.copyWith(
                            childCount: widget.comment.childCount + 1,
                            children: newChildren,
                          ));
                        },
                        opUserId: widget.opUserId,
                        onClick: widget.onClick,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
