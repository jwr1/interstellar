import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as mdf;
import 'package:markdown/markdown.dart' as md;
import 'package:interstellar/src/widgets/video.dart';

class VideoMarkdownSyntax extends md.InlineSyntax {
  VideoMarkdownSyntax() : super(r'!\[video\/mp4\]\((https:\/\/[^\s]+\.mp4)\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('video', match[1]!));
    return true;
  }
}

class VideoMarkdownBuilder extends mdf.MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var textContent = element.textContent;

    return VideoPlayer(Uri.parse(textContent));
  }
}