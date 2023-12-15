import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as flutter_markdown;
import 'package:url_launcher/url_launcher.dart';

class Markdown extends StatelessWidget {
  final String data;

  const Markdown(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return flutter_markdown.MarkdownBody(
      data: data,
      styleSheet: flutter_markdown.MarkdownStyleSheet(
          blockquoteDecoration: BoxDecoration(
        color: Colors.blue.shade500.withAlpha(50),
        borderRadius: BorderRadius.circular(2.0),
      )),
      onTapLink: (text, href, title) {
        if (href != null) {
          Uri uri = Uri.parse(href);

          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Open link in browser'),
              content: Text(uri.toString()),
              actions: <Widget>[
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse(href));
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
