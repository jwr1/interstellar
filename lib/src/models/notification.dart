import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/utils/models.dart';

part 'notification.freezed.dart';

@freezed
class NotificationListModel with _$NotificationListModel {
  const factory NotificationListModel({
    required List<NotificationModel> items,
    required String? nextPage,
  }) = _NotificationListModel;

  factory NotificationListModel.fromMbin(Map<String, Object?> json) =>
      NotificationListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) =>
                NotificationModel.fromMbin(post as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );
}

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    required NotificationType type,
    required String status,
    required Map<String, Object?>? subject,
  }) = _NotificationModel;

  factory NotificationModel.fromMbin(Map<String, Object?> json) =>
      NotificationModel(
        id: json['notificationId'] as int,
        type: notificationTypeEnumMap.entries
            .firstWhere((type) => json['type'] as String == type.value)
            .key,
        status: json['status'] as String,
        subject: json['subject'] as Map<String, Object?>?,
      );
}

enum NotificationType {
  entryCreatedNotification,
  entryEditedNotification,
  entryDeletedNotification,
  entryMentionedNotification,
  entryCommentCreatedNotification,
  entryCommentEditedNotification,
  entryCommentReplyNotification,
  entryCommentDeletedNotification,
  entryCommentMentionedNotification,
  postCreatedNotification,
  postEditedNotification,
  postDeletedNotification,
  postMentionedNotification,
  postCommentCreatedNotification,
  postCommentEditedNotification,
  postCommentReplyNotification,
  postCommentDeletedNotification,
  postCommentMentionedNotification,
  messageNotification,
  banNotification,
  magazineBanNotification,
}

const notificationTypeEnumMap = {
  NotificationType.entryCreatedNotification: 'entry_created_notification',
  NotificationType.entryEditedNotification: 'entry_edited_notification',
  NotificationType.entryDeletedNotification: 'entry_deleted_notification',
  NotificationType.entryMentionedNotification: 'entry_mentioned_notification',
  NotificationType.entryCommentCreatedNotification:
      'entry_comment_created_notification',
  NotificationType.entryCommentEditedNotification:
      'entry_comment_edited_notification',
  NotificationType.entryCommentReplyNotification:
      'entry_comment_reply_notification',
  NotificationType.entryCommentDeletedNotification:
      'entry_comment_deleted_notification',
  NotificationType.entryCommentMentionedNotification:
      'entry_comment_mentioned_notification',
  NotificationType.postCreatedNotification: 'post_created_notification',
  NotificationType.postEditedNotification: 'post_edited_notification',
  NotificationType.postDeletedNotification: 'post_deleted_notification',
  NotificationType.postMentionedNotification: 'post_mentioned_notification',
  NotificationType.postCommentCreatedNotification:
      'post_comment_created_notification',
  NotificationType.postCommentEditedNotification:
      'post_comment_edited_notification',
  NotificationType.postCommentReplyNotification:
      'post_comment_reply_notification',
  NotificationType.postCommentDeletedNotification:
      'post_comment_deleted_notification',
  NotificationType.postCommentMentionedNotification:
      'post_comment_mentioned_notification',
  NotificationType.messageNotification: 'message_notification',
  NotificationType.banNotification: 'ban_notification',
  NotificationType.magazineBanNotification: 'magazine_ban_notification',
};
