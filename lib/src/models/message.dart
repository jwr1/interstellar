import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/models/user.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class MessageListModel with _$MessageListModel {
  const factory MessageListModel({
    required List<MessageThreadModel> items,
    required PaginationModel pagination,
  }) = _MessageListModel;

  factory MessageListModel.fromJson(Map<String, Object?> json) =>
      _$MessageListModelFromJson(json);
}

@freezed
class MessageThreadModel with _$MessageThreadModel {
  const factory MessageThreadModel({
    required List<DetailedUserModel> participants,
    required int messageCount,
    required List<MessageItemModel> messages,
    required int threadId,
  }) = _MessageThreadModel;

  factory MessageThreadModel.fromJson(Map<String, Object?> json) =>
      _$MessageThreadModelFromJson(json);
}

@freezed
class MessageItemModel with _$MessageItemModel {
  const factory MessageItemModel({
    required UserModel sender,
    required String body,
    required String status,
    required int threadId,
    required DateTime createdAt,
    required int messageId,
  }) = _MessageItemModel;

  factory MessageItemModel.fromJson(Map<String, Object?> json) =>
      _$MessageItemModelFromJson(json);
}
