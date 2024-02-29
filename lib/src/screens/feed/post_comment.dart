import 'package:flutter/material.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/feed/post_comment_screen.dart';
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

  final CommentModel comment;
  final void Function(CommentModel) onUpdate;
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
          clipBehavior: Clip.antiAlias,
          child: Wrapper(
            shouldWrap: widget.onClick != null,
            parentBuilder: (child) =>
                InkWell(onTap: widget.onClick, child: child),
            child: ContentItem(
              originInstance: getNameHost(context, widget.comment.user.name),
              body: widget.comment.body ?? '_comment deleted_',
              createdAt: widget.comment.createdAt,
              user: widget.comment.user.name,
              userIcon: widget.comment.user.avatar,
              userIdOnClick: widget.comment.user.id,
              opUserId: widget.opUserId,
              boosts: widget.comment.boosts,
              isBoosted: widget.comment.myBoost == true,
              onBoost: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .api
                    .comments
                    .boost(widget.comment.postType, widget.comment.id);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              upVotes: widget.comment.upvotes,
              onUpVote: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .api
                    .comments
                    .vote(widget.comment.postType, widget.comment.id, 1,
                        widget.comment.myVote == 1 ? 0 : 1);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              isUpVoted: widget.comment.myVote == 1,
              downVotes: widget.comment.downvotes,
              isDownVoted: widget.comment.myVote == -1,
              onDownVote: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .api
                    .comments
                    .vote(widget.comment.postType, widget.comment.id, -1,
                        widget.comment.myVote == -1 ? 0 : -1);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              contentTypeName: 'Comment',
              onReply: whenLoggedIn(context, (body) async {
                var newSubComment = await context
                    .read<SettingsController>()
                    .api
                    .comments
                    .create(
                      widget.comment.postType,
                      widget.comment.postId,
                      body,
                      parentCommentId: widget.comment.id,
                    );

                widget.onUpdate(widget.comment.copyWith(
                  childCount: widget.comment.childCount + 1,
                  children: [newSubComment, ...widget.comment.children!],
                ));
              }),
              onReport: whenLoggedIn(context, (reason) async {
                await context
                    .read<SettingsController>()
                    .api
                    .comments
                    .report(widget.comment.postType, widget.comment.id, reason);
              }),
              onEdit: widget.comment.visibility != 'soft_deleted'
                  ? whenLoggedIn(context, (body) async {
                      var newValue = await context
                          .read<SettingsController>()
                          .api
                          .comments
                          .edit(
                            widget.comment.postType,
                            widget.comment.id,
                            body,
                          );

                      widget.onUpdate(newValue.copyWith(
                        childCount: widget.comment.childCount,
                        children: widget.comment.children,
                      ));
                    }, matchesUsername: widget.comment.user.name)
                  : null,
              onDelete: widget.comment.visibility != 'soft_deleted'
                  ? whenLoggedIn(context, () async {
                      await context
                          .read<SettingsController>()
                          .api
                          .comments
                          .delete(widget.comment.postType, widget.comment.id);
                      widget.onUpdate(widget.comment.copyWith(
                        body: '_comment deleted_',
                        upvotes: null,
                        downvotes: null,
                        boosts: null,
                        visibility: 'soft_deleted',
                      ));
                    }, matchesUsername: widget.comment.user.name)
                  : null,
              isCollapsed: _isCollapsed,
              onCollapse: widget.comment.childCount > 0
                  ? () => setState(() {
                        _isCollapsed = !_isCollapsed;
                      })
                  : null,
              openLinkUri: Uri.https(
                context.read<SettingsController>().instanceHost,
                context.read<SettingsController>().serverSoftware ==
                        ServerSoftware.lemmy
                    ? '/comment/${widget.comment.id}'
                    : '/m/${widget.comment.magazine.name}/${switch (widget.comment.postType) {
                        PostType.thread => 't',
                        PostType.microblog => 'p',
                      }}/${widget.comment.postId}/-/reply/${widget.comment.id}',
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
                  widget.comment.postType,
                  widget.comment.id,
                  opUserId: widget.opUserId,
                ),
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
