import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/utils/share.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/notification_control_segment.dart';
import 'package:interstellar/src/widgets/report_content.dart';
import 'package:interstellar/src/widgets/content_item/content_item.dart';

void showContentMenu(
    BuildContext context,
    ContentItem widget, {
      Function()? onEdit,
}) {
  final ac = context.read<AppController>();

  showModalBottomSheet(context: context, builder: (BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.boosts != null)
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onBoost,
                              icon: const Icon(Symbols.rocket_launch_rounded),
                              color: widget.isBoosted
                                  ? Colors.purple.shade400
                                  : null,
                            ),
                            Text(intFormat(widget.boosts!)),
                          ]
                        ),
                      if (widget.upVotes != null)
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onUpVote,
                              icon: const Icon(Symbols.arrow_upward_rounded),
                              color: widget.isUpVoted
                                  ? Colors.green.shade400
                                  : null,
                            ),
                            Text(intFormat(widget.upVotes!)),
                          ]
                        ),
                      if (widget.downVotes != null)
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onDownVote,
                              icon: const Icon(Symbols.arrow_downward_rounded),
                              color: widget.isDownVoted
                                  ? Colors.red.shade400
                                  : null,
                            ),
                            Text(intFormat(widget.downVotes!)),
                          ]
                        ),
                      if ((ac.serverSoftware == ServerSoftware.mbin &&
                          widget.contentTypeName != l(context).comment) ||
                          ac.serverSoftware == ServerSoftware.piefed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: NotificationControlSegment(
                            widget.notificationControlStatus!,
                            widget.onNotificationControlStatusChange!,
                          ),
                        ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(l(context).openInBrowser),
                  onTap: () => openWebpagePrimary(context, widget.openLinkUri!),
                ),
                ListTile(
                  title: Text(l(context).share),
                  onTap: () => shareUri(widget.openLinkUri!),
                ),
                if (widget.domain != null)
                  ListTile(
                    title: Text(l(context).moreFrom(widget.domain!)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DomainScreen(
                          widget.domainIdOnClick!,
                        ),
                      ),
                    ),
                  ),
                if (widget.activeBookmarkLists != null &&
                    widget.loadPossibleBookmarkLists != null &&
                    widget.onAddBookmarkToList != null &&
                    widget.onRemoveBookmarkFromList != null)
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l(context).bookmark),
                        const Icon(
                          Symbols.arrow_forward_rounded
                        )
                      ]
                    ),
                    onTap: () => showBookmarksMenu(context, widget),
                  ),
                if (widget.onReport != null)
                  ListTile(
                    title: Text(l(context).report),
                    onTap: () async {
                      final reportReason =
                          await reportContent(context, widget.contentTypeName);

                      if (reportReason != null) {
                        await widget.onReport!(reportReason);
                      }
                    },
                  ),
                if (widget.onEdit != null && onEdit != null)
                  ListTile(
                    title: Text(l(context).edit),
                    onTap: () {
                      onEdit();
                      Navigator.pop(context);
                    },
                  ),
                if (widget.onDelete != null)
                  ListTile(
                    title: Text(l(context).delete),
                    onTap: () {
                      // Don't show dialog if askBeforeDeleting is disabled
                      if (!context.read<AppController>().profile.askBeforeDeleting) {
                        widget.onDelete!();
                        Navigator.pop(context);
                        return;
                      }

                      showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(l(context).deleteX(widget.contentTypeName)),
                          actions: <Widget>[
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l(context).cancel),
                            ),
                            LoadingFilledButton(
                              onPressed: () async {
                                await widget.onDelete!();

                                if (!context.mounted) return;
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              label: Text(l(context).delete),
                              uesHaptics: true,
                            ),
                          ],
                          actionsOverflowAlignment: OverflowBarAlignment.center,
                          actionsOverflowButtonSpacing: 8,
                          actionsOverflowDirection: VerticalDirection.up,
                        ),
                      );
                    },
                  ),
                if (widget.body != null)
                  ListTile(
                    title: Text(l(context).viewSource),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l(context).viewSource),
                        content: Card.outlined(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SelectableText(widget.body!),
                          ),
                        ),
                        actions: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l(context).close),
                          ),
                          LoadingTonalButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: widget.body!),
                              );

                              if (!context.mounted) return;
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
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l(context).moderate),
                        const Icon(
                            Symbols.arrow_forward_rounded
                        )
                      ]
                    ),
                    onTap: () => showModerateMenu(context, widget),
                  ),
              ],
            )
          )
        )
      ],
    );
  });
}

void showBookmarksMenu(BuildContext context, ContentItem widget) async {
  final possibleBookMarkLists = await widget.loadPossibleBookmarkLists!();
  if (!context.mounted) return;

  showModalBottomSheet(context: context, builder: (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l(context).bookmark,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...{
                  ...widget.activeBookmarkLists!,
                  ...possibleBookMarkLists
                }.map(
                  (listName) => widget.activeBookmarkLists!.contains(listName)
                    ? ListTile(
                      title: Text(l(context).bookmark_removeFromX(listName)),
                      leading: const Icon(
                        Symbols.bookmark_rounded,
                        fill: 1
                      ),
                      onTap: () {
                        widget.onRemoveBookmarkFromList!(listName);
                        Navigator.pop(context);
                      },
                    )
                    : ListTile(
                      title: Text(l(context).bookmark_addToX(listName)),
                      leading: const Icon(
                        Symbols.bookmark_rounded,
                        fill: 1
                      ),
                      onTap: () {
                        widget.onAddBookmarkToList!(listName);
                        Navigator.pop(context);
                      }
                    )
                )
              ]
            )
          )
        ),
      ]
    );
  });
}

void showModerateMenu(BuildContext context, ContentItem widget) {
  showModalBottomSheet(context: context, builder: (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l(context).moderate,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(l(context).pin),
                  onTap: widget.onModeratePin,
                ),
                ListTile(
                  title: Text(l(context).notSafeForWork_mark),
                  onTap: widget.onModerateMarkNSFW,
                ),
                ListTile(
                  title: Text(l(context).delete),
                  onTap: widget.onModerateDelete,
                ),
                ListTile(
                  title: Text(l(context).banUser),
                  onTap: widget.onModerateBan,
                ),
              ]
            )
          )
        ),
      ]
    );
  });
}