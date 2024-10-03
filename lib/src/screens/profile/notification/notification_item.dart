import 'package:flutter/material.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/feed/post_comment_screen.dart';
import 'package:interstellar/src/screens/feed/post_page.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/markdown/markdown.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import './notification_count_controller.dart';

const notificationTitle = {
  NotificationType.entryCreated: 'created a thread',
  NotificationType.entryEdited: 'edited your thread',
  NotificationType.entryDeleted: 'deleted your thread',
  NotificationType.entryMentioned: 'mentioned you',
  NotificationType.entryCommentCreated: 'added a new comment',
  NotificationType.entryCommentEdited: 'edited your comment',
  NotificationType.entryCommentReply: 'replied to your comment',
  NotificationType.entryCommentDeleted: 'deleted your comment',
  NotificationType.entryCommentMentioned: 'mentioned you',
  NotificationType.postCreated: 'created a microblog',
  NotificationType.postEdited: 'edited your microblog',
  NotificationType.postDeleted: 'deleted your microblog',
  NotificationType.postMentioned: 'mentioned you',
  NotificationType.postCommentCreated: 'added a new comment',
  NotificationType.postCommentEdited: 'edited your comment',
  NotificationType.postCommentReply: 'replied to your comment',
  NotificationType.postCommentDeleted: 'deleted your comment',
  NotificationType.postCommentMentioned: 'mentioned you',
  NotificationType.message: 'messaged you',
  NotificationType.ban: 'banned you',
  NotificationType.reportCreated: 'report created',
  NotificationType.reportRejected: 'report rejected',
  NotificationType.reportApproved: 'report approved',
};

class NotificationItem extends StatefulWidget {
  const NotificationItem(this.item, this.onUpdate, {super.key});

  final NotificationModel item;
  final void Function(NotificationModel) onUpdate;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.item.type == null ||
        widget.item.status == null ||
        widget.item.subject == null) return const SizedBox();

    Map<String, Object?> rawUser = (widget.item.subject!['user'] ??
        widget.item.subject!['sender'] ??
        widget.item.subject!['bannedBy']) as Map<String, Object?>;
    UserModel user = UserModel.fromMbin(rawUser);
    MagazineModel? bannedMagazine = widget.item.type == NotificationType.ban &&
            widget.item.subject!['magazine'] != null
        ? MagazineModel.fromMbin(
            widget.item.subject!['magazine'] as Map<String, Object?>)
        : null;

    String body = (widget.item.subject!['body'] ??
        widget.item.subject!['reason'] ??
        '') as String;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      color: widget.item.status == NotificationStatus.new_
          ? null
          : Colors.transparent,
      child: InkWell(
        onTap: widget.item.subject!.containsKey('commentId')
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostCommentScreen(
                        widget.item.subject!.containsKey('postId')
                            ? PostType.microblog
                            : PostType.thread,
                        widget.item.subject!['commentId'] as int),
                  ),
                );
              }
            : widget.item.subject!.containsKey('entryId')
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostPage(
                          postType: PostType.thread,
                          postId: widget.item.subject!['entryId'] as int,
                        ),
                      ),
                    );
                  }
                : widget.item.subject!.containsKey('postId')
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PostPage(
                              postType: PostType.microblog,
                              postId: widget.item.subject!['postId'] as int,
                            ),
                          ),
                        );
                      }
                    : null,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 4,
            right: 4,
            bottom: 8,
            left: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DisplayName(
                      user.name,
                      icon: user.avatar,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserScreen(user.id),
                        ),
                      ),
                    ),
                  ),
                  Text(notificationTitle[widget.item.type]!),
                  if (bannedMagazine != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: DisplayName(
                        bannedMagazine.name,
                        icon: bannedMagazine.icon,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MagazineScreen(bannedMagazine.id),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  LoadingIconButton(
                    onPressed: () async {
                      final newNotification = await context
                          .read<SettingsController>()
                          .api
                          .notifications
                          .putRead(
                            widget.item.id,
                            widget.item.status == NotificationStatus.new_,
                          );

                      widget.onUpdate(newNotification);

                      if (!mounted) return;
                      context.read<NotificationCountController>().reload();
                    },
                    icon: Icon(
                      widget.item.status == NotificationStatus.new_
                          ? Symbols.mark_chat_read_rounded
                          : Symbols.mark_chat_unread_rounded,
                      fill: 0,
                    ),
                    tooltip: widget.item.status == NotificationStatus.new_
                        ? 'Mark as read'
                        : 'Mark as unread',
                  ),
                ],
              ),
              if (body.isNotEmpty)
                Markdown(body, getNameHost(context, user.name)),
            ],
          ),
        ),
      ),
    );
  }
}
