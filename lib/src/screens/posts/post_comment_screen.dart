import 'package:flutter/material.dart';
import 'package:interstellar/src/api/post_comments.dart';
import 'package:interstellar/src/api/posts.dart' as api_posts;
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class PostCommentScreen extends StatefulWidget {
  const PostCommentScreen(
    this.commentId, {
    this.opUserId,
    super.key,
  });

  final int commentId;
  final int? opUserId;

  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  PostCommentModel? _comment;

  @override
  void initState() {
    super.initState();

    fetchComment(context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost, widget.commentId)
        .then((value) => setState(() {
              _comment = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Comment${_comment != null ? ' by ${_comment!.user.username}' : ''}'),
      ),
      body: _comment != null
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: OutlinedButton(
                          onPressed: () async {
                            final parentEntry = await api_posts.fetchPost(
                              context.read<SettingsController>().httpClient,
                              context.read<SettingsController>().instanceHost,
                              _comment!.postId,
                            );
                            if (!mounted) return;
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PostPage(parentEntry, (newPage) {});
                            }));
                          },
                          child: const Text('Open OP'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: OutlinedButton(
                          onPressed: _comment!.rootId != null
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return PostCommentScreen(
                                        _comment!.rootId!,
                                      );
                                    }),
                                  );
                                }
                              : null,
                          child: const Text('Open Root'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: OutlinedButton(
                          onPressed: _comment!.parentId != null
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return PostCommentScreen(
                                        _comment!.parentId!,
                                      );
                                    }),
                                  );
                                }
                              : null,
                          child: const Text('Open Parent'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: PostComment(
                    _comment!,
                    (newComment) => setState(() {
                      _comment = newComment;
                    }),
                    opUserId: widget.opUserId,
                  ),
                )
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
