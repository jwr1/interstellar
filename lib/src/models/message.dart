import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/models.dart';

part 'message.freezed.dart';

@freezed
class MessageListModel with _$MessageListModel {
  const factory MessageListModel({
    required List<MessageThreadModel> items,
    required String? nextPage,
  }) = _MessageListModel;

  factory MessageListModel.fromMbin(Map<String, Object?> json) =>
      MessageListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) =>
                MessageThreadModel.fromMbin(post as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );
}

@freezed
class MessageThreadModel with _$MessageThreadModel {
  const factory MessageThreadModel({
    required List<DetailedUserModel> participants,
    required int messageCount,
    required List<MessageItemModel> messages,
    required int threadId,
  }) = _MessageThreadModel;

  factory MessageThreadModel.fromMbin(Map<String, Object?> json) =>
      MessageThreadModel(
        participants: (json['participants'] as List<dynamic>)
            .map((participant) =>
                DetailedUserModel.fromMbin(participant as Map<String, Object?>))
            .toList(),
        messageCount: json['messageCount'] as int,
        messages: (json['messages'] as List<dynamic>)
            .map((message) =>
                MessageItemModel.fromMbin(message as Map<String, Object?>))
            .toList(),
        threadId: json['threadId'] as int,
      );
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

  factory MessageItemModel.fromMbin(Map<String, Object?> json) =>
      MessageItemModel(
        sender: UserModel.fromMbin(json['sender'] as Map<String, Object?>),
        body: json['body'] as String,
        status: json['status'] as String,
        threadId: json['threadId'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        messageId: json['messageId'] as int,
      );
}
