import 'package:flutter/material.dart';
import 'package:interstellar/src/api/post_comments.dart' as api_comments;
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item.dart';
import 'package:provider/provider.dart';

class PostComment extends StatefulWidget {
  const PostComment(this.comment, this.onUpdate, {super.key});

  final api_comments.Comment comment;
  final void Function(api_comments.Comment) onUpdate;

  @override
  State<PostComment> createState() => _EntryCommentState();
}

class _EntryCommentState extends State<PostComment> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ContentItem(
        body: widget.comment.body,
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
          newValue.childCount = widget.comment.childCount;
          newValue.children = widget.comment.children;
          widget.onUpdate(newValue);
        }),
        upVotes: widget.comment.favourites,
        onUpVote: whenLoggedIn(context, () async {
          var newValue = await api_comments.putFavorite(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.comment.commentId,
          );
          newValue.childCount = widget.comment.childCount;
          newValue.children = widget.comment.children;
          widget.onUpdate(newValue);
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
          newValue.childCount = widget.comment.childCount;
          newValue.children = widget.comment.children;
          widget.onUpdate(newValue);
        }),
        showCollapse: true,
        onReply: (body) async {
          var newSubComment = await api_comments.postComment(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            body,
            widget.comment.postId,
            parentCommentId: widget.comment.commentId,
          );

          var newComment = widget.comment;
          newComment.childCount += 1;
          newComment.children!.insert(0, newSubComment);
          widget.onUpdate(newComment);
        },
        onEdit: whenLoggedIn(context, (body) async {
          var newComment = await api_comments.editComment(
              context.read<SettingsController>().httpClient,
              context.read<SettingsController>().instanceHost,
              widget.comment.commentId,
              body,
              widget.comment.lang,
              widget.comment.isAdult);
          setState(() {
            widget.comment.body = newComment.body;
          });
        }),
        onDelete: whenLoggedIn(context, () async {
          await api_comments.deleteComment(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.comment.commentId,
          );
          setState(() {
            widget.comment.body = "deleted";
          });
        }),
        child: widget.comment.childCount > 0
            ? Column(
                children: widget.comment.children!
                    .asMap()
                    .entries
                    .map((item) => PostComment(item.value, (newValue) {
                          var newComment = widget.comment;
                          newComment.children![item.key] = newValue;
                          widget.onUpdate(newComment);
                        }))
                    .toList(),
              )
            : null,
      ),
    );
  }
}
