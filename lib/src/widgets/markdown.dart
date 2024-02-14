import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as flutter_markdown;
import 'package:interstellar/src/widgets/markdown_mention.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';

class Markdown extends StatelessWidget {
  final String data;
  final String originInstance;

  const Markdown(this.data, this.originInstance, {super.key});

  @override
  Widget build(BuildContext context) {
    return flutter_markdown.MarkdownBody(
      data: data,
      styleSheet: flutter_markdown.MarkdownStyleSheet(
          blockquoteDecoration: BoxDecoration(
        color: Colors.blue.shade500.withAlpha(50),
        borderRadius: BorderRadius.circular(2.0),
      )),
      onTapLink: (text, href, title) async {
        if (href != null) {
          openWebpage(context, Uri.parse(href));
        }
      },
      inlineSyntaxes: [MentionMarkdownSyntax()],
      builders: {
        'mention': MentionMarkdownBuilder(originInstance: originInstance),
      },
    );
  }
}
