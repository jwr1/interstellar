import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/markdown_editor.dart';

class ActionBar extends StatefulWidget {
  final int? boosts;
  final int? upVotes;
  final int? downVotes;

  final bool isBoosted;
  final bool isUpVoted;
  final bool isDownVoted;
  final bool isCollapsed;

  final void Function()? onBoost;
  final void Function()? onUpVote;
  final void Function()? onDownVote;
  final void Function()? onCollapse;
  final Future<void> Function(String)? onReply;
  final Future<void> Function(String)? onEdit;
  final void Function()? onDelete;
  final String? Function()? initEdit;

  final List<Widget>? leadingWidgets;

  const ActionBar({
    super.key,
    this.boosts,
    this.upVotes,
    this.downVotes,
    this.isBoosted = false,
    this.isUpVoted = false,
    this.isDownVoted = false,
    this.isCollapsed = false,
    this.onBoost,
    this.onUpVote,
    this.onDownVote,
    this.onReply,
    this.onCollapse,
    this.onEdit,
    this.onDelete,
    this.initEdit,
    this.leadingWidgets,
  });

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  TextEditingController? _replyTextController;
  TextEditingController? _editTextController;
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            ...(widget.leadingWidgets ?? []),
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
            if (widget.onCollapse != null)
              IconButton(
                  tooltip: widget.isCollapsed ? 'Expand' : 'Collapse',
                  onPressed: widget.onCollapse,
                  icon: widget.isCollapsed
                      ? const Icon(Icons.expand_more)
                      : const Icon(Icons.expand_less)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: MenuAnchor(
                builder: (BuildContext context, MenuController controller, Widget? child) {
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
                    onPressed: widget.onEdit != null ? () => setState(() {
                      _editTextController = TextEditingController();
                    }) : null,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("Edit")
                    ),
                  ),
                  MenuItemButton(
                    onPressed: widget.onDelete,
                    child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("Delete")
                    ),
                  ),
                ]
              ),
            ),
            if (widget.boosts != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rocket_launch),
                      color: widget.isBoosted ? Colors.purple.shade400 : null,
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
                        color: widget.isUpVoted ? Colors.green.shade400 : null,
                        onPressed: widget.onUpVote,
                      ),
                    Text(intFormat(
                        (widget.upVotes ?? 0) - (widget.downVotes ?? 0))),
                    if (widget.downVotes != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        color: widget.isDownVoted ? Colors.red.shade400 : null,
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
                          await widget.onReply!(_replyTextController!.text);

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
                MarkdownEditor(_editTextController!..text = (widget.initEdit != null ? widget.initEdit!() : "")!),
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
          )
      ],
    );
  }
}
