import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/api/comments.dart' as api_comments;
import 'package:interstellar/src/screens/entries/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_item.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key, required this.item});

  final api_entries.EntryItem item;

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late Future<api_comments.Comments> comments;

  @override
  void initState() {
    super.initState();
    comments = api_comments.fetchComments(
        context.read<SettingsController>().instanceHost, widget.item.entryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
      ),
      body: ListView(
        children: [
          EntryItem(widget.item),
          FutureBuilder(
              future: comments,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: snapshot.data!.items
                          .map(
                              (subComment) => EntryComment(comment: subComment))
                          .toList(),
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              })
        ],
      ),
    );
  }
}
