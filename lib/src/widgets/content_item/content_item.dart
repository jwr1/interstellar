import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/models/bookmark_list.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils/share.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/image.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/markdown/drafts_controller.dart';
import 'package:interstellar/src/widgets/markdown/markdown.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:interstellar/src/widgets/report_content.dart';
import 'package:interstellar/src/widgets/user_status_icons.dart';
import 'package:interstellar/src/widgets/video.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import './content_item_link_panel.dart';

class ContentItem extends StatefulWidget {
  final String originInstance;

  final String? title;
  final ImageModel? image;
  final Uri? link;
  final String? body;
  final DateTime? createdAt;
  final DateTime? editedAt;

  final bool isPreview;
  final bool fullImageSize;
  final bool showMagazineFirst;

  final bool isPinned;
  final bool isNSFW;
  final bool isOC;

  final String? user;
  final ImageModel? userIcon;
  final int? userIdOnClick;
  final DateTime? userCakeDay;
  final bool userIsBot;
  final int? opUserId;

  final String? magazine;
  final ImageModel? magazineIcon;
  final int? magazineIdOnClick;

  final String? domain;
  final int? domainIdOnClick;

  final int? boosts;
  final bool isBoosted;
  final void Function()? onBoost;

  final int? upVotes;
  final bool isUpVoted;
  final void Function()? onUpVote;

  final int? downVotes;
  final bool isDownVoted;
  final void Function()? onDownVote;

  final String contentTypeName;
  final Uri? openLinkUri;
  final int? numComments;
  final Future<void> Function(String)? onReply;
  final Future<void> Function(String)? onReport;
  final Future<void> Function(String)? onEdit;
  final Future<void> Function()? onDelete;

  final Future<void> Function()? onModeratePin;
  final Future<void> Function()? onModerateMarkNSFW;
  final Future<void> Function()? onModerateDelete;
  final Future<void> Function()? onModerateBan;

  final bool isCollapsed;
  final void Function()? onCollapse;

  final String editDraftResourceId;
  final String replyDraftResourceId;

  final Set<String>? filterListWarnings;

  final List<String>? activeBookmarkLists;
  final Future<List<String>> Function()? loadPossibleBookmarkLists;
  final Future<void> Function()? onAddBookmark;
  final Future<void> Function(String)? onAddBookmarkToList;
  final Future<void> Function()? onRemoveBookmark;
  final Future<void> Function(String)? onRemoveBookmarkFromList;

  const ContentItem({
    required this.originInstance,
    this.title,
    this.image,
    this.link,
    this.body,
    this.createdAt,
    this.editedAt,
    this.isPreview = false,
    this.fullImageSize = false,
    this.showMagazineFirst = false,
    this.isPinned = false,
    this.isNSFW = false,
    this.isOC = false,
    this.user,
    this.userIcon,
    this.userIdOnClick,
    this.userCakeDay,
    this.userIsBot = false,
    this.opUserId,
    this.magazine,
    this.magazineIcon,
    this.magazineIdOnClick,
    this.domain,
    this.domainIdOnClick,
    this.boosts,
    this.isBoosted = false,
    this.onBoost,
    this.upVotes,
    this.isUpVoted = false,
    this.onUpVote,
    this.downVotes,
    this.isDownVoted = false,
    this.onDownVote,
    this.openLinkUri,
    this.numComments,
    required this.contentTypeName,
    this.onReply,
    this.onReport,
    this.onEdit,
    this.onDelete,
    this.onModeratePin,
    this.onModerateMarkNSFW,
    this.onModerateDelete,
    this.onModerateBan,
    this.isCollapsed = false,
    this.onCollapse,
    required this.editDraftResourceId,
    required this.replyDraftResourceId,
    this.filterListWarnings,
    this.activeBookmarkLists,
    this.loadPossibleBookmarkLists,
    this.onAddBookmark,
    this.onAddBookmarkToList,
    this.onRemoveBookmark,
    this.onRemoveBookmarkFromList,
    super.key,
  });

  @override
  State<ContentItem> createState() => _ContentItemState();
}

class _ContentItemState extends State<ContentItem> {
  TextEditingController? _replyTextController;
  TextEditingController? _editTextController;

  bool _bookmarkMenuWasOpened = false;
  List<String>? _possibleBookmarkLists;

  @override
  Widget build(BuildContext context) {
    final isVideo =
        widget.link != null && isSupportedYouTubeVideo(widget.link!);

    final Widget? userWidget = widget.user != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DisplayName(
                  widget.user!,
                  icon: widget.userIcon,
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
                if (widget.opUserId == widget.userIdOnClick)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Tooltip(
                      message: l(context).originalPoster_long,
                      triggerMode: TooltipTriggerMode.tap,
                      child: Text(
                        l(context).originalPoster_short,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
              icon: widget.magazineIcon,
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

    final editDraftController =
        context.watch<DraftsController>().auto(widget.editDraftResourceId);
    final replyDraftController =
        context.watch<DraftsController>().auto(widget.replyDraftResourceId);

    return LayoutBuilder(builder: (context, constrains) {
      final hasWideSize = constrains.maxWidth > 800;
      final isRightImage = hasWideSize;

      final double rightImageSize = hasWideSize ? 128 : 64;

      final imageOpenTitle = widget.title ?? widget.body ?? '';

      final imageWidget = widget.image == null
          ? null
          : isRightImage
              ? SizedBox(
                  height: rightImageSize,
                  width: rightImageSize,
                  child: AdvancedImage(
                    widget.image!,
                    fit: BoxFit.cover,
                    openTitle: imageOpenTitle,
                    enableBlur: widget.isNSFW &&
                        context
                            .watch<AppController>()
                            .profile
                            .coverMediaMarkedSensitive,
                  ),
                )
              : (!widget.fullImageSize
                  ? SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: AdvancedImage(
                        widget.image!,
                        fit: BoxFit.cover,
                        openTitle: imageOpenTitle,
                        enableBlur: widget.isNSFW,
                      ),
                    )
                  : AdvancedImage(
                      widget.image!,
                      openTitle: imageOpenTitle,
                      fit: BoxFit.scaleDown,
                      enableBlur: widget.isNSFW,
                    ));

      final titleStyle = hasWideSize
          ? Theme.of(context).textTheme.titleLarge!
          : Theme.of(context).textTheme.titleMedium!;
      final titleOverflow =
          widget.isPreview && context.watch<AppController>().profile.compactMode
              ? TextOverflow.ellipsis
              : null;

      return Column(
        children: <Widget>[
          if ((!isRightImage && imageWidget != null) ||
              (!widget.isPreview && isVideo))
            Wrapper(
              shouldWrap: widget.fullImageSize,
              parentBuilder: (child) => Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: child),
              child: (!widget.isPreview && isVideo)
                  ? VideoPlayer(widget.link!)
                  : imageWidget!,
            ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (widget.title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.title!,
                            style: titleStyle,
                            overflow: titleOverflow,
                          ),
                        ),
                      if (widget.link != null)
                        ContentItemLinkPanel(link: widget.link!),
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
                          if (widget.showMagazineFirst &&
                              magazineWidget != null)
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
                          if (!widget.showMagazineFirst &&
                              magazineWidget != null)
                            magazineWidget,
                        ],
                      ),
                      if (widget.body != null &&
                          widget.body!.isNotEmpty &&
                          !(widget.isPreview &&
                              context
                                  .watch<AppController>()
                                  .profile
                                  .compactMode))
                        Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: widget.isPreview
                                ? Text(
                                    widget.body!,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Markdown(
                                    widget.body!, widget.originInstance)),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: LayoutBuilder(builder: (context, constrains) {
                          final votingWidgets = [
                            if (widget.boosts != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Symbols.rocket_launch_rounded),
                                      color: widget.isBoosted
                                          ? Colors.purple.shade400
                                          : null,
                                      onPressed: widget.onBoost,
                                    ),
                                    Text(intFormat(widget.boosts!))
                                  ],
                                ),
                              ),
                            if (widget.upVotes != null ||
                                widget.downVotes != null)
                              Row(
                                children: [
                                  if (widget.upVotes != null)
                                    IconButton(
                                      icon: const Icon(
                                          Symbols.arrow_upward_rounded),
                                      color: widget.isUpVoted
                                          ? Colors.green.shade400
                                          : null,
                                      onPressed: widget.onUpVote,
                                    ),
                                  Text(intFormat((widget.upVotes ?? 0) -
                                      (widget.downVotes ?? 0))),
                                  if (widget.downVotes != null)
                                    IconButton(
                                      icon: const Icon(
                                          Symbols.arrow_downward_rounded),
                                      color: widget.isDownVoted
                                          ? Colors.red.shade400
                                          : null,
                                      onPressed: widget.onDownVote,
                                    ),
                                ],
                              ),
                          ];
                          final commentWidgets = [
                            if (widget.numComments != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Row(
                                  children: [
                                    const Icon(Symbols.comment_rounded),
                                    const SizedBox(width: 4),
                                    Text(intFormat(widget.numComments!))
                                  ],
                                ),
                              ),
                            if (widget.onReply != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  icon: const Icon(Symbols.reply_rounded),
                                  onPressed: () => setState(() {
                                    _replyTextController =
                                        TextEditingController();
                                  }),
                                ),
                              ),
                            if (widget.onCollapse != null)
                              IconButton(
                                  tooltip: widget.isCollapsed
                                      ? l(context).expand
                                      : l(context).collapse,
                                  onPressed: widget.onCollapse,
                                  icon: widget.isCollapsed
                                      ? const Icon(Symbols.expand_more_rounded)
                                      : const Icon(
                                          Symbols.expand_less_rounded)),
                          ];
                          final menuWidgets = [
                            if (widget.openLinkUri != null ||
                                widget.onReport != null ||
                                widget.onEdit != null ||
                                widget.onDelete != null)
                              MenuAnchor(
                                builder: (BuildContext context,
                                    MenuController controller, Widget? child) {
                                  return IconButton(
                                    icon: const Icon(Symbols.more_vert_rounded),
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                  );
                                },
                                menuChildren: [
                                  if (widget.openLinkUri != null)
                                    MenuItemButton(
                                      onPressed: () => openWebpagePrimary(
                                          context, widget.openLinkUri!),
                                      child: Text(l(context).openInBrowser),
                                    ),
                                  if (widget.openLinkUri != null)
                                    MenuItemButton(
                                      onPressed: () =>
                                          shareUri(widget.openLinkUri!),
                                      child: Text(l(context).share),
                                    ),
                                  if (widget.domain != null)
                                    MenuItemButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DomainScreen(
                                            widget.domainIdOnClick!,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                          l(context).moreFrom(widget.domain!)),
                                    ),
                                  if (widget.activeBookmarkLists != null &&
                                      widget.loadPossibleBookmarkLists !=
                                          null &&
                                      widget.onAddBookmarkToList != null &&
                                      widget.onRemoveBookmarkFromList != null)
                                    SubmenuButton(
                                      menuChildren: [
                                        ...{
                                          ...widget.activeBookmarkLists!,
                                          if (_possibleBookmarkLists != null)
                                            ..._possibleBookmarkLists!,
                                        }.map(
                                          (listName) => widget
                                                  .activeBookmarkLists!
                                                  .contains(listName)
                                              ? MenuItemButton(
                                                  onPressed: () => widget
                                                          .onRemoveBookmarkFromList!(
                                                      listName),
                                                  leadingIcon: const Icon(
                                                    Symbols.bookmark_rounded,
                                                    fill: 1,
                                                  ),
                                                  child: Text(l(context)
                                                      .bookmark_removeFromX(
                                                          listName)),
                                                )
                                              : MenuItemButton(
                                                  onPressed: () => widget
                                                          .onAddBookmarkToList!(
                                                      listName),
                                                  leadingIcon: const Icon(
                                                    Symbols.bookmark_rounded,
                                                    fill: 0,
                                                  ),
                                                  child: Text(l(context)
                                                      .bookmark_addToX(
                                                          listName)),
                                                ),
                                        ),
                                        if (_possibleBookmarkLists == null)
                                          const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                      ],
                                      onOpen: () async {
                                        if (_bookmarkMenuWasOpened) return;
                                        _bookmarkMenuWasOpened = true;

                                        final possibleBookmarkLists =
                                            await widget
                                                .loadPossibleBookmarkLists!();
                                        setState(() {
                                          _possibleBookmarkLists =
                                              possibleBookmarkLists;
                                        });
                                      },
                                      child: Text(l(context).bookmark),
                                    ),
                                  if (widget.onReport != null)
                                    MenuItemButton(
                                      onPressed: () async {
                                        final reportReason =
                                            await reportContent(context,
                                                widget.contentTypeName);

                                        if (reportReason != null) {
                                          await widget.onReport!(reportReason);
                                        }
                                      },
                                      child: Text(l(context).report),
                                    ),
                                  if (widget.onEdit != null)
                                    MenuItemButton(
                                      onPressed: () => setState(() {
                                        _editTextController =
                                            TextEditingController(
                                                text: widget.body);
                                      }),
                                      child: Text(l(context).edit),
                                    ),
                                  if (widget.onDelete != null)
                                    MenuItemButton(
                                      onPressed: () {
                                        // Don't show dialog if askBeforeDeleting is disabled
                                        if (!context
                                            .read<AppController>()
                                            .profile
                                            .askBeforeDeleting) {
                                          widget.onDelete!();
                                          return;
                                        }

                                        showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: Text(l(context).deleteX(
                                                widget.contentTypeName)),
                                            actions: <Widget>[
                                              OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(l(context).cancel),
                                              ),
                                              LoadingFilledButton(
                                                onPressed: () async {
                                                  await widget.onDelete!();

                                                  if (!mounted) return;
                                                  Navigator.pop(context);
                                                },
                                                label: Text(l(context).delete),
                                              ),
                                            ],
                                            actionsOverflowAlignment:
                                                OverflowBarAlignment.center,
                                            actionsOverflowButtonSpacing: 8,
                                            actionsOverflowDirection:
                                                VerticalDirection.up,
                                          ),
                                        );
                                      },
                                      child: Text(l(context).delete),
                                    ),
                                  if (widget.body != null)
                                    MenuItemButton(
                                      child: Text(l(context).viewSource),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(l(context).viewSource),
                                          content: Card.outlined(
                                            margin: EdgeInsets.zero,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child:
                                                  SelectableText(widget.body!),
                                            ),
                                          ),
                                          actions: [
                                            OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(l(context).close),
                                            ),
                                            LoadingTonalButton(
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                  ClipboardData(
                                                      text: widget.body!),
                                                );

                                                if (!mounted) return;
                                                Navigator.pop(context);
                                              },
                                              label: Text(l(context).copy),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (widget.onModeratePin != null ||
                                      widget.onModerateMarkNSFW != null ||
                                      widget.onModerateDelete != null ||
                                      widget.onModerateBan != null)
                                    SubmenuButton(
                                      menuChildren: [
                                        if (widget.onModeratePin != null)
                                          MenuItemButton(
                                            onPressed: widget.onModeratePin,
                                            child: Text(l(context).pin),
                                          ),
                                        if (widget.onModerateMarkNSFW != null)
                                          MenuItemButton(
                                            onPressed:
                                                widget.onModerateMarkNSFW,
                                            child: Text(
                                                l(context).notSafeForWork_mark),
                                          ),
                                        if (widget.onModerateDelete != null)
                                          MenuItemButton(
                                            onPressed: widget.onModerateDelete,
                                            child: Text(l(context).delete),
                                          ),
                                        if (widget.onModerateBan != null)
                                          MenuItemButton(
                                            onPressed: widget.onModerateBan,
                                            child: Text(l(context).banUser),
                                          ),
                                      ],
                                      child: Text(l(context).moderate),
                                    ),
                                ],
                              ),
                            if (widget.activeBookmarkLists != null)
                              widget.activeBookmarkLists!.isEmpty
                                  ? LoadingIconButton(
                                      onPressed: widget.onAddBookmark,
                                      icon: const Icon(
                                        Symbols.bookmark_rounded,
                                        fill: 0,
                                      ),
                                    )
                                  : LoadingIconButton(
                                      onPressed: widget.onRemoveBookmark,
                                      icon: const Icon(
                                        Symbols.bookmark_rounded,
                                        fill: 1,
                                      ),
                                    ),
                          ];

                          return constrains.maxWidth < 300
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: votingWidgets,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: <Widget>[
                                        ...commentWidgets,
                                        const Spacer(),
                                        ...menuWidgets,
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: <Widget>[
                                    ...commentWidgets,
                                    const Spacer(),
                                    ...menuWidgets,
                                    const SizedBox(width: 8),
                                    ...votingWidgets,
                                  ],
                                );
                        }),
                      ),
                      if (widget.onReply != null &&
                          _replyTextController != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              MarkdownEditor(
                                _replyTextController!,
                                originInstance: null,
                                draftController: replyDraftController,
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
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      if (widget.onEdit != null && _editTextController != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              MarkdownEditor(
                                _editTextController!,
                                originInstance: null,
                                draftController: editDraftController,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                      onPressed: () => setState(() {
                                            _editTextController!.dispose();
                                            _editTextController = null;
                                          }),
                                      child: Text(l(context).cancel)),
                                  const SizedBox(width: 8),
                                  LoadingFilledButton(
                                    onPressed: () async {
                                      await widget
                                          .onEdit!(_editTextController!.text);

                                      await editDraftController.discard();

                                      setState(() {
                                        _editTextController!.dispose();
                                        _editTextController = null;
                                      });
                                    },
                                    label: Text(l(context).submit),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isRightImage && imageWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageWidget,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
