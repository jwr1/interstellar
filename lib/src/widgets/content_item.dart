import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:interstellar/src/widgets/report_content.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:interstellar/src/widgets/video.dart';
import 'package:interstellar/src/widgets/wrapper.dart';

class ContentItem extends StatefulWidget {
  final String originInstance;

  final String? title;
  final String? image;
  final Uri? link;
  final Uri? video;
  final String? body;
  final DateTime? createdAt;

  final bool isPreview;
  final bool showMagazineFirst;

  final String? user;
  final String? userIcon;
  final int? userIdOnClick;
  final int? opUserId;

  final String? magazine;
  final String? magazineIcon;
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

  final bool isCollapsed;
  final void Function()? onCollapse;

  const ContentItem({
    required this.originInstance,
    this.title,
    this.image,
    this.link,
    this.video,
    this.body,
    this.createdAt,
    this.isPreview = false,
    this.showMagazineFirst = false,
    this.user,
    this.userIcon,
    this.userIdOnClick,
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
  final MenuController _menuController = MenuController();

  _onImageClick(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: widget.title != null ? Text(widget.title!) : null,
            backgroundColor: const Color(0x66000000),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(widget.image!),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget? userWidget = widget.user != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DisplayName(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.image != null || (!widget.isPreview && widget.video != null))
          Wrapper(
            shouldWrap: !widget.isPreview,
            parentBuilder: (child) => Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2,
                ),
                child: child),
            child: (!widget.isPreview && widget.video != null)
                ? VideoPlayer(widget.video!)
                : Wrapper(
                    shouldWrap: widget.video == null,
                    parentBuilder: (child) => InkWell(
                      onTap: () => _onImageClick(context),
                      child: child,
                    ),
                    child: widget.isPreview
                        ? Image.network(
                            widget.image!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(widget.image!),
                  ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: widget.link != null
                      ? InkWell(
                          child: Text(
                            widget.title!,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .apply(decoration: TextDecoration.underline),
                          ),
                          onTap: () {
                            openWebpage(context, widget.link!);
                          },
                        )
                      : Text(
                          widget.title!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                ),
              Row(
                children: [
                  if (!widget.showMagazineFirst && userWidget != null)
                    userWidget,
                  if (!widget.showMagazineFirst &&
                      widget.opUserId == widget.userIdOnClick)
                    const Padding(
                        padding: EdgeInsets.only(right: 10), child: Text("OP")),
                  if (widget.showMagazineFirst && magazineWidget != null)
                    magazineWidget,
                  if (widget.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        timeDiffFormat(widget.createdAt!),
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ),
                  if (widget.showMagazineFirst && userWidget != null)
                    userWidget,
                  if (widget.showMagazineFirst &&
                      widget.opUserId == widget.userIdOnClick)
                    const Padding(
                        padding: EdgeInsets.only(right: 10), child: Text("OP")),
                  if (!widget.showMagazineFirst && magazineWidget != null)
                    magazineWidget,
                  if (widget.domain != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        tooltip: widget.domain,
                        onPressed: widget.domainIdOnClick != null
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DomainScreen(
                                      widget.domainIdOnClick!,
                                    ),
                                  ),
                                )
                            : null,
                        icon: const Icon(Icons.public),
                        iconSize: 16,
                        style: const ButtonStyle(
                            minimumSize:
                                MaterialStatePropertyAll(Size.fromRadius(16))),
                      ),
                    ),
                ],
              ),
              if (widget.body != null) const SizedBox(height: 10),
              if (widget.body != null)
                widget.isPreview
                    ? Text(
                        widget.body!,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Markdown(widget.body!, widget.originInstance),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (context, constrains) {
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
                  if (widget.upVotes != null || widget.downVotes != null)
                    Row(
                      children: [
                        if (widget.upVotes != null)
                          IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            color:
                                widget.isUpVoted ? Colors.green.shade400 : null,
                            onPressed: widget.onUpVote,
                          ),
                        Text(intFormat(
                            (widget.upVotes ?? 0) - (widget.downVotes ?? 0))),
                        if (widget.downVotes != null)
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            color:
                                widget.isDownVoted ? Colors.red.shade400 : null,
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
                          _replyTextController = TextEditingController();
                        }),
                      ),
                    ),
                  if (widget.onCollapse != null)
                    IconButton(
                        tooltip: widget.isCollapsed ? 'Expand' : 'Collapse',
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
                      builder: (BuildContext context, MenuController controller,
                          Widget? child) {
                        return IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            if (_menuController.isOpen) {
                              _menuController.close();
                            } else {
                              _menuController.open();
                            }
                          },
                        );
                      },
                      controller: _menuController,
                      menuChildren: [
                        if (widget.openLinkUri != null)
                          MenuItemButton(
                            onPressed: () =>
                                openWebpage(context, widget.openLinkUri!),
                            child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("Open Link")),
                          ),
                        if (widget.onReport != null)
                          MenuItemButton(
                            onPressed: () async {
                              final reportReason = await reportContent(
                                  context, widget.contentTypeName);

                              if (reportReason != null) {
                                await widget.onReport!(reportReason);
                              }
                            },
                            child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("Report")),
                          ),
                        if (widget.onEdit != null)
                          MenuItemButton(
                            onPressed: () => setState(() {
                              _editTextController =
                                  TextEditingController(text: widget.body);
                            }),
                            child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("Edit")),
                          ),
                        if (widget.onDelete != null)
                          MenuItemButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text('Delete ${widget.contentTypeName}'),
                                actions: <Widget>[
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      widget.onDelete!();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                                actionsOverflowAlignment:
                                    OverflowBarAlignment.center,
                                actionsOverflowButtonSpacing: 8,
                                actionsOverflowDirection: VerticalDirection.up,
                              ),
                            ),
                            child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("Delete")),
                          ),
                      ],
                    ),
                ];

                return constrains.maxWidth < 300
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
              if (widget.onReply != null && _replyTextController != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextEditor(_replyTextController!, isMarkdown: true),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                              onPressed: () => setState(() {
                                    _replyTextController!.dispose();
                                    _replyTextController = null;
                                  }),
                              child: const Text('Cancel')),
                          const SizedBox(width: 8),
                          FilledButton(
                              onPressed: () async {
                                // Wait in case of errors before closing
                                await widget
                                    .onReply!(_replyTextController!.text);

                                setState(() {
                                  _replyTextController!.dispose();
                                  _replyTextController = null;
                                });
                              },
                              child: const Text('Submit'))
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
                      TextEditor(_editTextController!, isMarkdown: true),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                              onPressed: () => setState(() {
                                    _editTextController!.dispose();
                                    _editTextController = null;
                                  }),
                              child: const Text('Cancel')),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              // Wait in case of errors before closing
                              await widget.onEdit!(_editTextController!.text);

                              setState(() {
                                _editTextController!.dispose();
                                _editTextController = null;
                              });
                            },
                            child: const Text('Submit'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
