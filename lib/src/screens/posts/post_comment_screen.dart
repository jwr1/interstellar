import 'package:flutter/material.dart';
import 'package:interstellar/src/api/post_comments.dart';
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/screens/posts/post_comment.dart';
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
                  child: PostComment(
                    _comment!,
                    (newComment) => setState(() {
                      _comment = newComment;
                    }), opUserId: widget.opUserId
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
