import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/image.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/markdown/markdown.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:interstellar/src/widgets/report_content.dart';
import 'package:interstellar/src/widgets/user_status_icons.dart';
import 'package:interstellar/src/widgets/video.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
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

  const ContentItem({
    required this.originInstance,
    this.title,
    this.image,
    this.link,
    this.body,
    this.createdAt,
    this.editedAt,
    this.isPreview = false,
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
    super.key,
  });

  @override
  State<ContentItem> createState() => _ContentItemState();
}

class _ContentItemState extends State<ContentItem> {
  TextEditingController? _replyTextController;
  TextEditingController? _editTextController;

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.link != null && isSupportedVideo(widget.link!);

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

    return LayoutBuilder(builder: (context, constrains) {
      final hasWideSize = constrains.maxWidth > 800;
      final isRightImage =
          switch (context.watch<SettingsController>().postImagePosition) {
        PostImagePosition.auto => hasWideSize,
        PostImagePosition.top => false,
        PostImagePosition.right => true,
      };

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
                    enableBlur: widget.isNSFW,
                  ),
                )
              : (widget.isPreview
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
      final titleOverflow = widget.isPreview &&
              context.watch<SettingsController>().postCompactPreview
          ? TextOverflow.ellipsis
          : null;

      return Column(
        children: <Widget>[
          if ((!isRightImage && imageWidget != null) ||
              (!widget.isPreview && isVideo))
            Wrapper(
              shouldWrap: !widget.isPreview,
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
                          if (widget.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Tooltip(
                                message: l(context).pinnedInMagazine,
                                triggerMode: TooltipTriggerMode.tap,
                                child: const Icon(Icons.push_pin, size: 20),
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
                                  .watch<SettingsController>()
                                  .postCompactPreview))
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
                                      icon: const Icon(Icons.rocket_launch),
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
                                      icon: const Icon(Icons.arrow_upward),
                                      color: widget.isUpVoted
                                          ? Colors.green.shade400
                                          : null,
                                      onPressed: widget.onUpVote,
                                    ),
                                  Text(intFormat((widget.upVotes ?? 0) -
                                      (widget.downVotes ?? 0))),
                                  if (widget.downVotes != null)
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward),
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
                                    const Icon(Icons.comment),
                                    const SizedBox(width: 4),
                                    Text(intFormat(widget.numComments!))
                                  ],
                                ),
                              ),
                            if (widget.onReply != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  icon: const Icon(Icons.reply),
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
                                      ? const Icon(Icons.expand_more)
                                      : const Icon(Icons.expand_less)),
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
                                    icon: const Icon(Icons.more_vert),
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
                                      onPressed: () => showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: Text(l(context)
                                              .deleteX(widget.contentTypeName)),
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
                                      ),
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
                              MarkdownEditor(_replyTextController!),
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
                              MarkdownEditor(_editTextController!),
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
