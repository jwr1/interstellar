import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/old/shared.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class NotificationListModel with _$NotificationListModel {
  const factory NotificationListModel({
    required List<NotificationModel> items,
    required PaginationModel pagination,
  }) = _NotificationListModel;

  factory NotificationListModel.fromJson(Map<String, Object?> json) =>
      _$NotificationListModelFromJson(json);
}

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int notificationId,
    required NotificationType type,
    required String status,
    required Map<String, Object?> subject,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, Object?> json) =>
      _$NotificationModelFromJson(json);
}

@JsonEnum(fieldRename: FieldRename.snake)
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
}
