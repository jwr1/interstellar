import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/feed/post_comment_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/ban_dialog.dart';
import 'package:interstellar/src/widgets/content_item/content_item.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class PostComment extends StatefulWidget {
  const PostComment(
    this.comment,
    this.onUpdate, {
    this.opUserId,
    this.onClick,
    this.canModerate = false,
    super.key,
  });

  final CommentModel comment;
  final void Function(CommentModel) onUpdate;
  final int? opUserId;
  final void Function()? onClick;
  final bool canModerate;

  @override
  State<PostComment> createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  final ExpandableController _expandableController =
      ExpandableController(initialExpanded: true);

  @override
  Widget build(BuildContext context) {
    final canModerate = widget.comment.canAuthUserModerate ?? false;

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
              image: widget.comment.image,
              body: widget.comment.body ?? '_${l10n(context).commentDeleted}_',
              createdAt: widget.comment.createdAt,
              editedAt: widget.comment.editedAt,
              user: widget.comment.user.name,
              userIcon: widget.comment.user.avatar,
              userIdOnClick: widget.comment.user.id,
              userCakeDay: widget.comment.user.createdAt,
              userIsBot: widget.comment.user.isBot,
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
              contentTypeName: l10n(context).comment,
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

                      if (!mounted) return;

                      widget.onUpdate(widget.comment.copyWith(
                        body: '_${l10n(context).commentDeleted}_',
                        upvotes: null,
                        downvotes: null,
                        boosts: null,
                        visibility: 'soft_deleted',
                      ));
                    }, matchesUsername: widget.comment.user.name)
                  : null,
              onModerateDelete: !canModerate
                  ? null
                  : () async {
                      final newValue = await context
                          .read<SettingsController>()
                          .api
                          .moderation
                          .commentDelete(
                            widget.comment.postType,
                            widget.comment.id,
                            true,
                          );

                      widget.onUpdate(newValue.copyWith(
                        childCount: widget.comment.childCount,
                        children: widget.comment.children,
                      ));
                    },
              onModerateBan: !canModerate
                  ? null
                  : () async {
                      await openBanDialog(context,
                          user: widget.comment.user,
                          magazine: widget.comment.magazine);
                    },
              isCollapsed: !_expandableController.expanded,
              onCollapse: widget.comment.childCount > 0
                  ? () => setState(() {
                        _expandableController.toggle();
                      })
                  : null,
              openLinkUri: Uri.https(
                context.watch<SettingsController>().instanceHost,
                context.watch<SettingsController>().serverSoftware ==
                        ServerSoftware.lemmy
                    ? '/comment/${widget.comment.id}'
                    : '/m/${widget.comment.magazine.name}/${switch (widget.comment.postType) {
                        PostType.thread => 't',
                        PostType.microblog => 'p',
                      }}/${widget.comment.postId}/-/${switch (widget.comment.postType) {
                        PostType.thread => 'comment',
                        PostType.microblog => 'reply',
                      }}/${widget.comment.id}',
              ),
            ),
          ),
        ),
        if (widget.comment.childCount > 0 &&
            _expandableController.expanded &&
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
            child: Text(l10n(context).openReplies(widget.comment.childCount)),
          ),
        if (widget.comment.childCount > 0)
          Expandable(
            controller: _expandableController,
            collapsed: Container(),
            expanded: Container(
              margin: const EdgeInsets.only(left: 1),
              padding: const EdgeInsets.only(left: 9),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 2,
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
                          canModerate: widget.canModerate,
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
