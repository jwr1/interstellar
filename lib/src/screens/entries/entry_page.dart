import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/api/comments.dart' as api_comments;
import 'package:interstellar/src/screens/entries/entry_comment.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
          if (widget.item.image?.storageUrl != null)
            Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2,
                ),
                child: Image.network(
                  widget.item.image!.storageUrl,
                )),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.item.type == 'link' && widget.item.url != null
                    ? InkWell(
                        child: Text(
                          widget.item.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .apply(decoration: TextDecoration.underline),
                        ),
                        onTap: () {
                          launchUrl(Uri.parse(widget.item.url!));
                        },
                      )
                    : Text(
                        widget.item.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    DisplayName(widget.item.magazine.name),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        timeDiffFormat(widget.item.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ),
                    DisplayName(widget.item.user.username),
                  ],
                ),
                if (widget.item.body != null && widget.item.body!.isNotEmpty)
                  const SizedBox(height: 10),
                if (widget.item.body != null && widget.item.body!.isNotEmpty)
                  MarkdownBody(data: widget.item.body!),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    const Icon(Icons.comment),
                    const SizedBox(width: 4),
                    Text(widget.item.numComments.toString()),
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
                    Text(widget.item.uv.toString()),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {},
                    ),
                    Text((widget.item.favourites - widget.item.dv).toString()),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () {},
                    ),
                  ],
                ),
                FutureBuilder(
                    future: comments,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: snapshot.data!.items
                                .map((subComment) =>
                                    EntryComment(comment: subComment))
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
          ),
        ],
      ),
    );
  }
}
