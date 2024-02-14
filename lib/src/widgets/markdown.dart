import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as flutter_markdown;
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/api/users.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:provider/provider.dart';

class Markdown extends StatefulWidget {
  final String data;
  final String originInstance;

  const Markdown(this.data, this.originInstance, {super.key});

  @override
  State<Markdown> createState() => _MarkdownState();
}

class _MarkdownState extends State<Markdown> {
  @override
  Widget build(BuildContext context) {
    return flutter_markdown.MarkdownBody(
      data: widget.data,
      inlineSyntaxes: [MentionsMarkdownSyntax()],
      styleSheet: flutter_markdown.MarkdownStyleSheet(
          blockquoteDecoration: BoxDecoration(
        color: Colors.blue.shade500.withAlpha(50),
        borderRadius: BorderRadius.circular(2.0),
      )),
      onTapLink: (text, href, title) async {
        if (href != null) {
          if (href.startsWith('@') || href.startsWith('!')) {
            final modifier = href[0];
            final split = href.substring(1).split('@');
            final name = split[0];
            final host = split.length > 1 ? split[1] : widget.originInstance;

            if (modifier == '@') {
              final user = await fetchUserByName(
                context.read<SettingsController>().httpClient,
                context.read<SettingsController>().instanceHost,
                context.read<SettingsController>().instanceHost == host
                    ? name
                    : '@$name@$host',
              );

              // Check BuildContext
              if (!mounted) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserScreen(user.userId, initData: user),
                ),
              );
            } else {
              final magazine = await fetchMagazineByName(
                context.read<SettingsController>().httpClient,
                context.read<SettingsController>().instanceHost,
                context.read<SettingsController>().instanceHost == host
                    ? name
                    : '$name@$host',
              );

              // Check BuildContext
              if (!mounted) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MagazineScreen(magazine.magazineId, initData: magazine),
                ),
              );
            }
          } else {
            openWebpage(context, Uri.parse(href));
          }
        }
      },
    );
  }
}

class MentionsMarkdownSyntax extends markdown.InlineSyntax {
  /*
    Should match the following patterns:

    https://kbin.social/m/interstellar@kbin.earth
    kbin.social/m/interstellar@kbin.earth
    https://kbin.earth/m/interstellar
    kbin.earth/m/interstellar
    /m/interstellar@kbin.earth
    /m/interstellar
    !interstellar@kbin.earth
    !interstellar
    https://lemmy.world/c/fediverse
    lemmy.world/c/fediverse
    /c/fediverse

    https://kbin.social/u/@jwr1@kbin.earth
    kbin.social/u/@jwr1@kbin.earth
    https://kbin.earth/u/jwr1
    kbin.earth/u/jwr1
    /u/@jwr1@kbin.earth
    /u/jwr1
    @jwr1@kbin.earth
    @jwr1
  */
  static const String _pattern =
      r'(?:(?:(?:https?:\/\/)?([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))?\/([umc])\/|(@|!))@?([a-zA-Z0-9._%+-]+)(?:@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))?';

  MentionsMarkdownSyntax() : super(_pattern);

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final urlDomain = match.group(1);
    final urlModifier = match.group(2);
    final modifier = match.group(3) ?? (urlModifier == 'u' ? '@' : '!');
    final name = match.group(4)!;
    final host = match.group(5) ?? urlDomain;

    final result = '$modifier$name${host != null ? '@$host' : ''}';

    final anchor = markdown.Element.text('a', match[0]!);

    anchor.attributes['href'] = result;
    parser.addNode(anchor);

    return true;
  }
}
