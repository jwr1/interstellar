import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart' as api_comments;
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';

class EntryComment extends StatelessWidget {
  const EntryComment({super.key, required this.comment});

  final api_comments.Comment comment;

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
                  onPressed: () {},
                ),
                Text(intFormat(comment.uv)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {},
                ),
                Text(intFormat(comment.favourites - comment.dv)),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () {},
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
                    .map((subComment) => EntryComment(comment: subComment))
                    .toList(),
              )
          ],
        ),
      ),
    );
  }
}
