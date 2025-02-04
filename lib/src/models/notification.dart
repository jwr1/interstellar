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
    required NotificationType? type,
    required NotificationStatus? status,
    required Map<String, Object?>? subject,
  }) = _NotificationModel;

  factory NotificationModel.fromMbin(Map<String, Object?> json) =>
      NotificationModel(
        id: json['notificationId'] as int,
        type: notificationTypeMap[json['type']],
        status: notificationStatusMap[json['status']],
        subject: json['subject'] as Map<String, Object?>?,
      );
}

enum NotificationStatus { all, new_, read }

const notificationStatusMap = {
  'all': NotificationStatus.all,
  'new': NotificationStatus.new_,
  'read': NotificationStatus.read,
};

enum NotificationType {
  entryCreated,
  entryEdited,
  entryDeleted,
  entryMentioned,
  entryCommentCreated,
  entryCommentEdited,
  entryCommentReply,
  entryCommentDeleted,
  entryCommentMentioned,
  postCreated,
  postEdited,
  postDeleted,
  postMentioned,
  postCommentCreated,
  postCommentEdited,
  postCommentReply,
  postCommentDeleted,
  postCommentMentioned,
  message,
  ban,
  reportCreated,
  reportRejected,
  reportApproved
}

const notificationTypeMap = {
  'entry_created_notification': NotificationType.entryCreated,
  'entry_edited_notification': NotificationType.entryEdited,
  'entry_deleted_notification': NotificationType.entryDeleted,
  'entry_mentioned_notification': NotificationType.entryMentioned,
  'entry_comment_created_notification': NotificationType.entryCommentCreated,
  'entry_comment_edited_notification': NotificationType.entryCommentEdited,
  'entry_comment_reply_notification': NotificationType.entryCommentReply,
  'entry_comment_deleted_notification': NotificationType.entryCommentDeleted,
  'entry_comment_mentioned_notification':
      NotificationType.entryCommentMentioned,
  'post_created_notification': NotificationType.postCreated,
  'post_edited_notification': NotificationType.postEdited,
  'post_deleted_notification': NotificationType.postDeleted,
  'post_mentioned_notification': NotificationType.postMentioned,
  'post_comment_created_notification': NotificationType.postCommentCreated,
  'post_comment_edited_notification': NotificationType.postCommentEdited,
  'post_comment_reply_notification': NotificationType.postCommentReply,
  'post_comment_deleted_notification': NotificationType.postCommentDeleted,
  'post_comment_mentioned_notification': NotificationType.postCommentMentioned,
  'message_notification': NotificationType.message,
  'ban_notification': NotificationType.ban,
  'report_created_notification': NotificationType.reportCreated,
  'report_rejected_notification': NotificationType.reportRejected,
  'report_approved_notification': NotificationType.reportApproved,
};

enum NotificationControlStatus {
  default_,
  muted,
  loud;

  factory NotificationControlStatus.fromJson(String json) => {
        'Default': NotificationControlStatus.default_,
        'Muted': NotificationControlStatus.muted,
        'Loud': NotificationControlStatus.loud,
      }[json]!;

  String toJson() => {
        NotificationControlStatus.default_: 'Default',
        NotificationControlStatus.muted: 'Muted',
        NotificationControlStatus.loud: 'Loud',
      }[this]!;
}
