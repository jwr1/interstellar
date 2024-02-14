import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as flutter_markdown;
import 'package:interstellar/src/api/magazines.dart';
import 'package:interstellar/src/api/users.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:provider/provider.dart';

class MentionMarkdownSyntax extends markdown.InlineSyntax {
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

    [name here](MENTION)
    [name here](MENTION "title here")
  */
  static const String _pattern =
      r'(?:\[.*?\]\()?(?:(?:(?:https?:\/\/)?([a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}))?\/([umc])\/@?|(@|!))([a-zA-Z0-9_]+)(?:@([a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}))?(?:(?:\s*".*?")?\))?';

  MentionMarkdownSyntax() : super(_pattern);

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final urlDomain = match.group(1);
    final urlModifier = match.group(2);
    final modifier = match.group(3) ?? (urlModifier == 'u' ? '@' : '!');
    final name = match.group(4)!;
    final host = match.group(5) ?? urlDomain;

    final result = '$modifier$name${host != null ? '@$host' : ''}';

    final node = markdown.Element.text('mention', result);

    parser.addNode(node);

    return true;
  }
}

class MentionMarkdownBuilder extends flutter_markdown.MarkdownElementBuilder {
  final String originInstance;

  MentionMarkdownBuilder({required this.originInstance});

  @override
  Widget? visitElementAfter(
      markdown.Element element, TextStyle? preferredStyle) {
    return RichText(
      text: TextSpan(children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MentionWidget(element.textContent, originInstance),
        ),
      ]),
    );
  }
}

class MentionWidget extends StatefulWidget {
  final String name;
  final String originInstance;

  const MentionWidget(this.name, this.originInstance, {super.key});

  @override
  State<MentionWidget> createState() => MentionWidgetState();
}

class MentionWidgetState extends State<MentionWidget> {
  late String _displayName;
  String? _icon;
  void Function()? _onClick;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  void _fetchData() async {
    final modifier = widget.name[0];
    final split = widget.name.substring(1).split('@');
    final name = split[0];
    final host = split.length > 1 ? split[1] : widget.originInstance;

    setState(() {
      _displayName = modifier + name;
    });

    try {
      if (modifier == '@') {
        final user = await fetchUserByName(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          context.read<SettingsController>().instanceHost == host
              ? name
              : '@$name@$host',
        );

        setState(() {
          _icon = user.avatar?.storageUrl;
          _onClick = () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserScreen(user.userId, initData: user),
              ),
            );
          };
        });
      } else if (modifier == '!') {
        final magazine = await fetchMagazineByName(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          context.read<SettingsController>().instanceHost == host
              ? name
              : '$name@$host',
        );

        setState(() {
          _icon = magazine.icon?.storageUrl;
          _onClick = () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    MagazineScreen(magazine.magazineId, initData: magazine),
              ),
            );
          };
        });
      }
    } catch (_) {
      // User/Magazine not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(_displayName),
      avatar: _icon != null ? Avatar(_icon!) : null,
      onPressed: _onClick,
      visualDensity:
          const VisualDensity(vertical: VisualDensity.minimumDensity),
    );
  }
}
