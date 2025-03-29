import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item/swipe_item.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/image.dart';
import 'package:interstellar/src/widgets/user_status_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/markdown/drafts_controller.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';

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
  final int? userIdOnClick;
  final DateTime? userCakeDay;
  final bool userIsBot;

  final String? magazine;
  final int? magazineIdOnClick;

  final int? upVotes;
  final int? downVotes;
  final int? numComments;

  final String replyDraftResourceId;

  final Set<String>? filterListWarnings;
  final List<String>? activeBookmarkLists;

  final void Function()? onUpVote;
  final void Function()? onDownVote;
  final void Function()? onBoost;
  final Future<void> Function()? onAddBookmark;
  final Future<void> Function()? onRemoveBookmark;
  final Future<void> Function(String)? onReply;
  final Future<void> Function()? onModeratePin;
  final Future<void> Function()? onModerateMarkNSFW;
  final Future<void> Function()? onModerateDelete;
  final Future<void> Function()? onModerateBan;

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
    this.userIdOnClick,
    this.userCakeDay,
    this.userIsBot = false,
    this.magazine,
    this.magazineIdOnClick,
    this.upVotes,
    this.downVotes,
    this.numComments,
    required this.replyDraftResourceId,
    this.filterListWarnings,
    this.activeBookmarkLists,
    this.onUpVote,
    this.onDownVote,
    this.onBoost,
    this.onAddBookmark,
    this.onRemoveBookmark,
    this.onReply,
    this.onModeratePin,
    this.onModerateMarkNSFW,
    this.onModerateDelete,
    this.onModerateBan,
    super.key,
  });

  @override
  State<ContentItemCompactPost> createState() => _ContentItemCompactPostState();
}

class _ContentItemCompactPostState extends State<ContentItemCompactPost> {
  TextEditingController? _replyTextController;

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
              enableBlur: widget.isNSFW &&
                  context
                      .watch<AppController>()
                      .profile
                      .coverMediaMarkedSensitive,
            ),
          );

    final Widget? userWidget = widget.user != null
        ? Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: DisplayName(
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
                  ),
                  UserStatusIcons(
                    cakeDay: widget.userCakeDay,
                    isBot: widget.userIsBot,
                  ),
                ],
              ),
            ),
          )
        : null;
    final Widget? magazineWidget = widget.magazine != null
        ? Flexible(
            child: Padding(
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
            ),
          )
        : null;

    final replyDraftController =
        context.watch<DraftsController>().auto(widget.replyDraftResourceId);

    return Wrapper(
        shouldWrap: context.watch<AppController>().profile.enableSwipeActions,
        parentBuilder: (child) => SwipeItem(
              onUpVote: widget.onUpVote,
              onDownVote: widget.onDownVote,
              onBoost: widget.onBoost,
              onBookmark: () async {
                if (widget.activeBookmarkLists != null &&
                    widget.onAddBookmark != null &&
                    widget.onRemoveBookmark != null) {
                  widget.activeBookmarkLists!.isEmpty
                      ? widget.onAddBookmark!()
                      : widget.onRemoveBookmark!();
                }
              },
              onReply: widget.onReply != null
                  ? () => setState(() {
                        _replyTextController = TextEditingController();
                      })
                  : () {},
              onModeratePin: widget.onModeratePin,
              onModerateMarkNSFW: widget.onModerateMarkNSFW,
              onModerateDelete: widget.onModerateDelete,
              onModerateBan: widget.onModerateBan,
              child: child,
            ),
        child: Row(
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
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.filterListWarnings?.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Tooltip(
                              message: l(context).filterListWarningX(
                                  widget.filterListWarnings!.join(', ')),
                              triggerMode: TooltipTriggerMode.tap,
                              child: const Icon(
                                Symbols.warning_amber_rounded,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (widget.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Tooltip(
                              message: l(context).pinnedInMagazine,
                              triggerMode: TooltipTriggerMode.tap,
                              child: const Icon(Symbols.push_pin_rounded,
                                  size: 20),
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300),
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
                    if (widget.onReply != null && _replyTextController != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            MarkdownEditor(
                              _replyTextController!,
                              originInstance: null,
                              draftController: replyDraftController,
                              autoFocus: true,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                    onPressed: () => setState(() {
                                          _replyTextController!.dispose();
                                          _replyTextController = null;
                                        }),
                                    child: Text(l(context).cancel)),
                                const SizedBox(width: 8),
                                LoadingFilledButton(
                                  onPressed: () async {
                                    await widget
                                        .onReply!(_replyTextController!.text);

                                    await replyDraftController.discard();

                                    setState(() {
                                      _replyTextController!.dispose();
                                      _replyTextController = null;
                                    });
                                  },
                                  label: Text(l(context).submit),
                                  uesHaptics: true,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (imageWidget != null) imageWidget,
          ],
        ));
  }
}
