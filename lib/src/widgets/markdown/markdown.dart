import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as mdf;
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/widgets/image.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';

import './markdown_mention.dart';
import './markdown_spoiler.dart';
import './markdown_subscript_superscript.dart';

class Markdown extends StatelessWidget {
  final String data;
  final String originInstance;

  const Markdown(this.data, this.originInstance, {super.key});

  @override
  Widget build(BuildContext context) {
    return mdf.MarkdownBody(
      data: data,
      styleSheet: mdf.MarkdownStyleSheet(
          blockquoteDecoration: BoxDecoration(
        color: Colors.blue.shade500.withAlpha(50),
        borderRadius: BorderRadius.circular(2.0),
      )),
      onTapLink: (text, href, title) async {
        if (href != null) {
          openWebpage(context, Uri.parse(href));
        }
      },
      imageBuilder: (uri, title, alt) {
        return AdvancedImage(
          ImageModel(
            src: uri.toString(),
            altText: alt,
            blurHash: null,
            blurHashWidth: null,
            blurHashHeight: null,
          ),
          openTitle: title ?? '',
        );
      },
      inlineSyntaxes: [
        SubscriptMarkdownSyntax(),
        SuperscriptMarkdownSyntax(),
        MentionMarkdownSyntax(),
      ],
      blockSyntaxes: [
        SpoilerMarkdownSyntax(),
      ],
      builders: {
        'sub': SubscriptMarkdownBuilder(),
        'sup': SuperscriptMarkdownBuilder(),
        'mention': MentionMarkdownBuilder(originInstance: originInstance),
        'spoiler': SpoilerMarkdownBuilder(originInstance: originInstance),
      },
    );
  }
}
