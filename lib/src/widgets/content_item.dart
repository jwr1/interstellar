import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:interstellar/src/widgets/markdown_editor.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:interstellar/src/widgets/video.dart';

class ContentItem extends StatefulWidget {
  final String? title;
  final String? image;
  final Uri? link;
  final Uri? video;
  final String? body;
  final DateTime? createdAt;

  final bool isPreview;
  final bool showCollapse;
  final bool showMagazineFirst;

  final String? user;
  final String? userIcon;
  final int? userIdOnClick;

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

  final int? numComments;
  final Future<void> Function(String)? onReply;
  final Future<void> Function(String)? onEdit;
  final Future<void> Function()? onDelete;

  final Widget? child;

  const ContentItem(
      {this.title,
      this.image,
      this.link,
      this.video,
      this.body,
      this.createdAt,
      this.isPreview = false,
      this.showCollapse = false,
      this.showMagazineFirst = false,
      this.user,
      this.userIcon,
      this.userIdOnClick,
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
      this.numComments,
      this.onReply,
      this.onEdit,
      this.onDelete,
      this.child,
      super.key});

  @override
  State<ContentItem> createState() => _ContentItemState();
}

class _ContentItemState extends State<ContentItem> {
  bool _isCollapsed = false;
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
        if (!widget.isPreview && widget.video != null)
          VideoPlayer(widget.video!),
        if (widget.image != null &&
            !(!widget.isPreview && widget.video != null))
          widget.isPreview
              ? (widget.video != null
                  ? Image.network(
                      widget.image!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : InkWell(
                      onTap: () => _onImageClick(context),
                      child: Image.network(
                        widget.image!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ))
              : Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                  ),
                  child: InkWell(
                    onTap: () => _onImageClick(context),
                    child: Image.network(widget.image!),
                  )),
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
                    : Markdown(widget.body!),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
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
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: const Icon(Icons.reply),
                        onPressed: () => setState(() {
                          _replyTextController = TextEditingController();
                        }),
                      ),
                    ),
                  if (widget.showCollapse && widget.child != null)
                    IconButton(
                        tooltip: _isCollapsed ? 'Expand' : 'Collapse',
                        onPressed: () => setState(() {
                              _isCollapsed = !_isCollapsed;
                            }),
                        icon: _isCollapsed
                            ? const Icon(Icons.expand_more)
                            : const Icon(Icons.expand_less)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: MenuAnchor(
                        builder: (BuildContext context,
                            MenuController controller, Widget? child) {
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
                          MenuItemButton(
                            onPressed: widget.onEdit != null
                                ? () => setState(() {
                                      _editTextController =
                                          TextEditingController();
                                    })
                                : null,
                            child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("Edit")),
                          ),
                          MenuItemButton(
                            onPressed: widget.onDelete,
                            child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("Delete")),
                          ),
                        ]),
                  ),
                  if (widget.boosts != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          if (widget.upVotes != null)
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              color: widget.isUpVoted
                                  ? Colors.green.shade400
                                  : null,
                              onPressed: widget.onUpVote,
                            ),
                          Text(intFormat(
                              (widget.upVotes ?? 0) - (widget.downVotes ?? 0))),
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
                    )
                ],
              ),
              if (widget.onReply != null && _replyTextController != null)
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
                      MarkdownEditor(
                        _editTextController!..text = widget.body ?? '',
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
                              child: const Text('Submit'))
                        ],
                      )
                    ],
                  ),
                ),
              if (widget.child != null && !_isCollapsed)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: widget.child,
                )
            ],
          ),
        ),
      ],
    );
  }
}
