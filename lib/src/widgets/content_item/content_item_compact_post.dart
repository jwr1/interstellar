import 'package:flutter/material.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/image.dart';
import 'package:interstellar/src/widgets/user_status_icons.dart';
import 'package:material_symbols_icons/symbols.dart';

class ContentItemCompactPost extends StatefulWidget {
  final String? title;
  final ImageModel? image;
  final Uri? link;
  final DateTime? createdAt;
  final DateTime? editedAt;

  final bool showMagazineFirst;

  final bool isPinned;
  final bool isNSFW;
  final bool isOC;

  final String? user;
  final ImageModel? userIcon;
  final int? userIdOnClick;
  final DateTime? userCakeDay;
  final bool userIsBot;

  final String? magazine;
  final ImageModel? magazineIcon;
  final int? magazineIdOnClick;

  final int? upVotes;
  final int? downVotes;
  final int? numComments;

  const ContentItemCompactPost({
    this.title,
    this.image,
    this.link,
    this.createdAt,
    this.editedAt,
    this.showMagazineFirst = false,
    this.isPinned = false,
    this.isNSFW = false,
    this.isOC = false,
    this.user,
    this.userIcon,
    this.userIdOnClick,
    this.userCakeDay,
    this.userIsBot = false,
    this.magazine,
    this.magazineIcon,
    this.magazineIdOnClick,
    this.upVotes,
    this.downVotes,
    this.numComments,
    super.key,
  });

  @override
  State<ContentItemCompactPost> createState() => _ContentItemCompactPostState();
}

class _ContentItemCompactPostState extends State<ContentItemCompactPost> {
  @override
  Widget build(BuildContext context) {
    // TODO: Figure out how to use full existing height of row, instead of fixed value.
    final imageWidget = widget.image == null
        ? null
        : SizedBox(
            height: 96,
            width: 96,
            child: AdvancedImage(
              widget.image!,
              fit: BoxFit.cover,
              openTitle: widget.title,
              enableBlur: widget.isNSFW,
            ),
          );

    final Widget? userWidget = widget.user != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DisplayName(
                  widget.user!,
                  onTap: widget.userIdOnClick != null
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserScreen(
                                widget.userIdOnClick!,
                              ),
                            ),
                          )
                      : null,
                ),
                UserStatusIcons(
                  cakeDay: widget.userCakeDay,
                  isBot: widget.userIsBot,
                ),
              ],
            ),
          )
        : null;
    final Widget? magazineWidget = widget.magazine != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DisplayName(
              widget.magazine!,
              onTap: widget.magazineIdOnClick != null
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MagazineScreen(
                            widget.magazineIdOnClick!,
                          ),
                        ),
                      )
                  : null,
            ),
          )
        : null;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Tooltip(
                          message: l(context).pinnedInMagazine,
                          triggerMode: TooltipTriggerMode.tap,
                          child: const Icon(Symbols.push_pin_rounded, size: 20),
                        ),
                      ),
                    if (widget.isNSFW)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Tooltip(
                          message: l(context).notSafeForWork_long,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Text(
                            l(context).notSafeForWork_short,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (widget.isOC)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Tooltip(
                          message: l(context).originalContent_long,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Text(
                            l(context).originalContent_short,
                            style: const TextStyle(
                              color: Colors.lightGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (!widget.showMagazineFirst && userWidget != null)
                      userWidget,
                    if (widget.showMagazineFirst && magazineWidget != null)
                      magazineWidget,
                    if (widget.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Tooltip(
                          message: l(context).createdAt(
                                  dateTimeFormat(widget.createdAt!)) +
                              (widget.editedAt == null
                                  ? ''
                                  : '\n${l(context).editedAt(dateTimeFormat(widget.editedAt!))}'),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Text(
                            dateDiffFormat(widget.createdAt!),
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                    if (widget.showMagazineFirst && userWidget != null)
                      userWidget,
                    if (!widget.showMagazineFirst && magazineWidget != null)
                      magazineWidget,
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(l(context).pointsX(
                        (widget.upVotes ?? 0) - (widget.downVotes ?? 0))),
                    const Text(' · '),
                    Text(l(context).commentsX(widget.numComments ?? 0)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (imageWidget != null) imageWidget,
      ],
    );
  }
}
