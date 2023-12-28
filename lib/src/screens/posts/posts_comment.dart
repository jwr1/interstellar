import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart' as api_comments;
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/action_bar.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class PostComment extends StatefulWidget {
  const PostComment(this.comment, this.onUpdate, {super.key});

  final api_comments.Comment comment;
  final void Function(api_comments.Comment) onUpdate;

  @override
  State<PostComment> createState() => _EntryCommentState();
}

class _EntryCommentState extends State<PostComment> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 0, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DisplayName(
                  widget.comment.user.username,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserScreen(
                          widget.comment.user.userId,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    timeDiffFormat(widget.comment.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Markdown(widget.comment.body),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ActionBar(
                boosts: widget.comment.uv,
                upVotes: widget.comment.favourites,
                downVotes: widget.comment.dv,
                isBoosted: widget.comment.userVote == 1,
                isUpVoted: widget.comment.isFavourited == true,
                isDownVoted: widget.comment.userVote == -1,
                isCollapsed: _isCollapsed,
                onBoost: whenLoggedIn(context, () async {
                  var newValue = await api_comments.putVote(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    widget.comment.commentId,
                    1,
                    api_comments.CommentType.post
                  );
                  newValue.childCount = widget.comment.childCount;
                  newValue.children = widget.comment.children;
                  widget.onUpdate(newValue);
                }),
                onUpVote: whenLoggedIn(context, () async {
                  var newValue = await api_comments.putFavorite(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    widget.comment.commentId,
                    api_comments.CommentType.post
                  );
                  newValue.childCount = widget.comment.childCount;
                  newValue.children = widget.comment.children;
                  widget.onUpdate(newValue);
                }),
                onDownVote: whenLoggedIn(context, () async {
                  var newValue = await api_comments.putVote(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    widget.comment.commentId,
                    -1,
                    api_comments.CommentType.post
                  );
                  newValue.childCount = widget.comment.childCount;
                  newValue.children = widget.comment.children;
                  widget.onUpdate(newValue);
                }),
                onCollapse: widget.comment.childCount > 0
                    ? () => setState(() {
                          _isCollapsed = !_isCollapsed;
                        })
                    : null,
                onReply: (body) async {
                  var newSubComment = await api_comments.postComment(
                    context.read<SettingsController>().httpClient,
                    context.read<SettingsController>().instanceHost,
                    body,
                    widget.comment.entryPostId,
                    api_comments.CommentType.post,
                    parentCommentId: widget.comment.commentId,
                  );

                  var newComment = widget.comment;
                  newComment.childCount += 1;
                  newComment.children!.insert(0, newSubComment);
                  widget.onUpdate(newComment);
                },
              ),
            ),
            const SizedBox(height: 4),
            if (!_isCollapsed && widget.comment.childCount > 0)
              Column(
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
          ],
        ),
      ),
    );
  }
}
