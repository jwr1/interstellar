import 'package:flutter/material.dart';
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class EntryCommentScreen extends StatefulWidget {
  const EntryCommentScreen(
    this.commentId, {
    this.opUserId,
    super.key,
  });

  final int commentId;
  final int? opUserId;

  @override
  State<EntryCommentScreen> createState() => _EntryCommentScreenState();
}

class _EntryCommentScreenState extends State<EntryCommentScreen> {
  EntryCommentModel? _comment;

  @override
  void initState() {
    super.initState();

    context
        .read<SettingsController>()
        .kbinAPI
        .entryComments
        .get(widget.commentId)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: OutlinedButton(
                        onPressed: () async {
                          final parentEntry = await context
                              .read<SettingsController>()
                              .kbinAPI
                              .entries
                              .get(_comment!.entryId);
                          if (!mounted) return;
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return EntryPage(parentEntry, (newPage) {});
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
                                    return EntryCommentScreen(
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
                                    return EntryCommentScreen(
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
