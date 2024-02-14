import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart' as flutter_markdown;
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:provider/provider.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/screens/settings/settings_controller.dart';

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
          openWebpage(context, Uri.parse(href));
        }
      },
      builders: <String, flutter_markdown.MarkdownElementBuilder>{
        'mention': MentionBuilder()
      },
      inlineSyntaxes: [
        MentionSyntax()
      ],
    );
  }
}

class MentionSyntax extends md.InlineSyntax {

  static const String _pattern = "@([a-zA-Z0-9._-]+)(@([a-zA-Z0-9._-]+))*";

  MentionSyntax() : super(_pattern);
  
  @override
  RegExp get pattern => RegExp(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    String username = match[0]!;
    parser.addNode(md.Element.text("mention", username));
    return true;
  }
}

class MentionBuilder extends flutter_markdown.MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () async {
            final user = await api_users.fetchUserByName(
              context.read<SettingsController>().httpClient,
              context.read<SettingsController>().instanceHost,
              element.textContent);

            if (!context.mounted) return;

            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => UserScreen(
                user.userId,
                initData: user,
              ))
            );
          },
          child: Text(
            element.textContent,
            style: const TextStyle(
              color: Colors.blue
            ),
          ),
        );
      },
    );
  }
}