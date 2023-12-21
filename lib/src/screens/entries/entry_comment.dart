import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart' as api_comments;
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class EntryComment extends StatelessWidget {
  const EntryComment(this.comment, this.onUpdate, {super.key});

  final api_comments.Comment comment;
  final void Function(api_comments.Comment) onUpdate;

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
                  comment.user.username,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserScreen(
                          comment.user.userId,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    timeDiffFormat(comment.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.rocket_launch),
                  color: comment.userVote == 1 ? Colors.purple.shade400 : null,
                  onPressed: whenLoggedIn(context, () async {
                    var newValue = await api_comments.putVote(
                      context.read<SettingsController>().httpClient,
                      context.read<SettingsController>().instanceHost,
                      comment.commentId,
                      1,
                    );
                    newValue.childCount = comment.childCount;
                    newValue.children = comment.children;
                    onUpdate(newValue);
                  }),
                ),
                Text(intFormat(comment.uv)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  color: comment.isFavourited == true
                      ? Colors.green.shade400
                      : null,
                  onPressed: whenLoggedIn(context, () async {
                    var newValue = await api_comments.putFavorite(
                      context.read<SettingsController>().httpClient,
                      context.read<SettingsController>().instanceHost,
                      comment.commentId,
                    );
                    newValue.childCount = comment.childCount;
                    newValue.children = comment.children;
                    onUpdate(newValue);
                  }),
                ),
                Text(intFormat(comment.favourites - comment.dv)),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  color: comment.userVote == -1 ? Colors.red.shade400 : null,
                  onPressed: whenLoggedIn(context, () async {
                    var newValue = await api_comments.putVote(
                      context.read<SettingsController>().httpClient,
                      context.read<SettingsController>().instanceHost,
                      comment.commentId,
                      -1,
                    );
                    newValue.childCount = comment.childCount;
                    newValue.children = comment.children;
                    onUpdate(newValue);
                  }),
                ),
                const SizedBox(
                  width: 6,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 12),
              child: Markdown(comment.body),
            ),
            if (comment.childCount > 0)
              Column(
                children: comment.children!
                    .asMap()
                    .entries
                    .map((item) => EntryComment(item.value, (newValue) {
                          var newComment = comment;
                          newComment.children![item.key] = newValue;
                          onUpdate(newComment);
                        }))
                    .toList(),
              )
          ],
        ),
      ),
    );
  }
}
