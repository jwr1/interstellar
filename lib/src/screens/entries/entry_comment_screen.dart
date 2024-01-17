import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_comment.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class EntryCommentScreen extends StatefulWidget {
  const EntryCommentScreen(
    this.commentId, {
    super.key,
  });

  final int commentId;

  @override
  State<EntryCommentScreen> createState() => _EntryCommentScreenState();
}

class _EntryCommentScreenState extends State<EntryCommentScreen> {
  EntryCommentModel? _comment;

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
                  child: EntryComment(
                    _comment!,
                    (newComment) => setState(() {
                      _comment = newComment;
                    }),
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
