import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as flutter_markdown;

class Markdown extends StatelessWidget {
  final String data;

  const Markdown(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return flutter_markdown.MarkdownBody(data: data);
  }
}
