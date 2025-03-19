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

  factory MessageListModel.fromLemmy(Map<String, Object?> json, int id, int limit) {
    Map<int, Map<String, Object?>> threads = {};
    int messageCount = (json['private_messages'] as List<dynamic>).length;

    for (var message in json['private_messages'] as List<dynamic>) {
      var creator = (message)['creator'] as Map<String, Object?>;
      var recipient = (message)['recipient'] as Map<String, Object?>;

      var threadId = 0;
      if ((creator['id'] as int) == id) {
        threadId = (recipient['actor_id'] as String).hashCode;
      } else {
        threadId = (creator['actor_id'] as String).hashCode;
      }

      if (threads[threadId] == null) {
        threads[threadId] = {
          'threadId': threadId,
          'messages': <Map<String, Object?>>[],
          'participants': [creator, recipient],
        };
      }

      message['threadId'] = threadId;
      (threads[threadId]!['messages'] as List<Map<String, Object?>>)
          .add(message);
    }

    var nextPage = threads.isEmpty || messageCount < limit
        ? null
        : (int.parse(json['next_page'] as String? ?? '1') + 1).toString();

    return MessageListModel(
        items: threads.values.map((thread) =>
            MessageThreadModel.fromLemmy(thread)).toList(),
        nextPage: nextPage
    );
  }

  factory MessageListModel.fromPiefed(Map<String, Object?> json, int id, int limit) {
    Map<int, Map<String, Object?>> threads = {};
    int messageCount = (json['private_messages'] as List<dynamic>).length;

    for (var message in json['private_messages'] as List<dynamic>) {
      var creator = (message)['creator'] as Map<String, Object?>;
      var recipient = (message)['recipient'] as Map<String, Object?>;

      var threadId = 0;
      if ((creator['id'] as int) == id) {
        threadId = (recipient['actor_id'] as String).hashCode;
      } else {
        threadId = (creator['actor_id'] as String).hashCode;
      }

      if (threads[threadId] == null) {
        threads[threadId] = {
          'threadId': threadId,
          'messages': <Map<String, Object?>>[],
          'participants': [creator, recipient],
        };
      }

      message['threadId'] = threadId;
      (threads[threadId]!['messages'] as List<Map<String, Object?>>)
          .add(message);
    }

    var nextPage = threads.isEmpty || messageCount < limit
        ? null
        : (int.parse(json['next_page'] as String? ?? '1') + 1).toString();

    return MessageListModel(
      items: threads.values.map((thread) =>
          MessageThreadModel.fromPiefed(thread)).toList(),
      nextPage: nextPage
    );
  }
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

  factory MessageThreadModel.fromLemmy(Map<String, Object?> json) =>
      MessageThreadModel(
        participants: (json['participants'] as List<dynamic>)
            .map((participant) =>
              DetailedUserModel.fromLemmy({
                'person': participant as Map<String, Object?>
              }))
            .toList(),
        messageCount: (json['messages'] as List<Map<String, Object?>>).length,
        messages: (json['messages'] as List<Map<String, Object?>>)
            .map((message) =>
              MessageItemModel.fromLemmy(message))
            .toList(),
        threadId: json['threadId'] as int
    );

  factory MessageThreadModel.fromPiefed(Map<String, Object?> json) =>
      MessageThreadModel(
        participants: (json['participants'] as List<dynamic>)
            .map((participant) =>
                DetailedUserModel.fromPiefed({
                  'person': participant as Map<String, Object?>
                }))
            .toList(),
        messageCount: (json['messages'] as List<Map<String, Object?>>).length,
        messages: (json['messages'] as List<Map<String, Object?>>).reversed
            .map((message) =>
              MessageItemModel.fromPiefed(message))
            .toList(),
        threadId: json['threadId'] as int
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

  factory MessageItemModel.fromLemmy(Map<String, Object?> json) {
    final pm = json['private_message'] as Map<String, Object?>;

    return MessageItemModel(
      sender: UserModel.fromLemmy(json['creator'] as Map<String, Object?>),
      body: pm['content'] as String,
      status: (pm['read'] as bool).toString(),
      threadId: json['threadId'] as int,
      createdAt: DateTime.parse(pm['published'] as String),
      messageId: pm['id'] as int,
    );
  }

  factory MessageItemModel.fromPiefed(Map<String, Object?> json) {
    final pm = json['private_message'] as Map<String, Object?>;

    return MessageItemModel(
      sender: UserModel.fromPiefed(json['creator'] as Map<String, Object?>),
      body: pm['content'] as String,
      status: (pm['read'] as bool).toString(),
      threadId: json['threadId'] as int,
      createdAt: DateTime.parse(pm['published'] as String),
      messageId: pm['id'] as int,
    );
  }
}
