import 'package:flutter/material.dart';
import 'package:interstellar/src/api/notifications.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/notification.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/entries/entry_comment_screen.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/posts/post_comment_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

const notificationTitle = {
  NotificationType.entryCreatedNotification: 'created a thread',
  NotificationType.entryEditedNotification: 'edited your thread',
  NotificationType.entryDeletedNotification: 'deleted your thread',
  NotificationType.entryMentionedNotification: 'mentioned you',
  NotificationType.entryCommentCreatedNotification: 'added a new comment',
  NotificationType.entryCommentEditedNotification: 'edited your comment',
  NotificationType.entryCommentReplyNotification: 'replied to your comment',
  NotificationType.entryCommentDeletedNotification: 'deleted your comment',
  NotificationType.entryCommentMentionedNotification: 'mentioned you',
  NotificationType.postCreatedNotification: 'created a post',
  NotificationType.postEditedNotification: 'edited your post',
  NotificationType.postDeletedNotification: 'deleted your post',
  NotificationType.postMentionedNotification: 'mentioned you',
  NotificationType.postCommentCreatedNotification: 'added a new comment',
  NotificationType.postCommentEditedNotification: 'edited your comment',
  NotificationType.postCommentReplyNotification: 'replied to your comment',
  NotificationType.postCommentDeletedNotification: 'deleted your comment',
  NotificationType.postCommentMentionedNotification: 'mentioned you',
  NotificationType.messageNotification: 'messaged you',
  NotificationType.banNotification: 'banned you from',
};

class NotificationItem extends StatelessWidget {
  const NotificationItem(this.item, this.onUpdate, {super.key});

  final NotificationModel item;
  final void Function(NotificationModel) onUpdate;

  @override
  Widget build(BuildContext context) {
    Map<String, Object?> rawUser = (item.subject['user'] ??
        item.subject['sender'] ??
        item.subject['bannedBy']) as Map<String, Object?>;
    UserModel user = UserModel.fromJson(rawUser);
    MagazineModel? bannedMagazine =
        item.type == NotificationType.banNotification &&
                item.subject['magazine'] != null
            ? MagazineModel.fromJson(
                item.subject['magazine'] as Map<String, Object?>)
            : null;

    String body =
        (item.subject['body'] ?? item.subject['reason'] ?? '') as String;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      surfaceTintColor: item.status == 'new' ? Colors.amber : null,
      child: InkWell(
        onTap: item.subject.containsKey('commentId')
            ? () {
                final commentId = item.subject['commentId'] as int;
                if (item.subject.containsKey('entryId')) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EntryCommentScreen(commentId),
                    ),
                  );
                } else if (item.subject.containsKey('postId')) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostCommentScreen(commentId),
                    ),
                  );
                }
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: DisplayName(
                      user.username,
                      icon: user.avatar?.storageUrl,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserScreen(user.userId),
                        ),
                      ),
                    ),
                  ),
                  Text(notificationTitle[item.type]!),
                  if (bannedMagazine != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: DisplayName(
                        bannedMagazine.name,
                        icon: bannedMagazine.icon?.storageUrl,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MagazineScreen(bannedMagazine.magazineId),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      final newNotification = await putNotificationRead(
                        context.read<SettingsController>().httpClient,
                        context.read<SettingsController>().instanceHost,
                        item.notificationId,
                        item.status == 'new',
                      );

                      onUpdate(newNotification);
                    },
                    icon: Icon(item.status == 'new'
                        ? Icons.mark_email_read
                        : Icons.mark_email_unread),
                    tooltip: item.status == 'new'
                        ? 'Mark as read'
                        : 'Mark as unread',
                  ),
                ],
              ),
              if (body.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Markdown(body),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
