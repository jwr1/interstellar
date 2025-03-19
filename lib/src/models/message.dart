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

  factory MessageListModel.fromLemmy(
    Map<String, Object?> json,
    int myUserId,
  ) {
    Map<int, Map<String, Object?>> threads = {};

    for (var message in json['private_messages'] as List<dynamic>) {
      var creator = (message)['creator'] as Map<String, Object?>;
      var recipient = (message)['recipient'] as Map<String, Object?>;

      var threadId = 0;
      if ((creator['id'] as int) == myUserId) {
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

    return MessageListModel(
      items: threads.values
          .map((thread) => MessageThreadModel.fromLemmy(thread))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  factory MessageListModel.fromPiefed(
    Map<String, Object?> json,
    int myUserId,
  ) {
    Map<int, Map<String, Object?>> threads = {};

    for (var message in json['private_messages'] as List<dynamic>) {
      var creator = (message)['creator'] as Map<String, Object?>;
      var recipient = (message)['recipient'] as Map<String, Object?>;

      var threadId = 0;
      if ((creator['id'] as int) == myUserId) {
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

    return MessageListModel(
      items: threads.values
          .map((thread) => MessageThreadModel.fromPiefed(thread))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }
}

@freezed
class MessageThreadModel with _$MessageThreadModel {
  const factory MessageThreadModel({
    required int id,
    required List<DetailedUserModel> participants,
    required List<MessageItemModel> messages,
    required String? nextPage,
  }) = _MessageThreadModel;

  factory MessageThreadModel.fromMbin(Map<String, Object?> json) =>
      MessageThreadModel(
        id: json['threadId'] as int,
        participants: (json['participants'] as List<dynamic>)
            .map((participant) =>
                DetailedUserModel.fromMbin(participant as Map<String, Object?>))
            .toList(),
        messages: ((json['messages'] ?? json['items']) as List<dynamic>)
            .map((message) =>
                MessageItemModel.fromMbin(message as Map<String, Object?>))
            .toList(),
        nextPage: json['pagination'] == null
            ? null
            : mbinCalcNextPaginationPage(
                json['pagination'] as Map<String, Object?>),
      );

  factory MessageThreadModel.fromLemmy(Map<String, Object?> json) =>
      MessageThreadModel(
        id: json['threadId'] as int,
        participants: (json['participants'] as List<dynamic>)
            .map((participant) => DetailedUserModel.fromLemmy(
                {'person': participant as Map<String, Object?>}))
            .toList(),
        messages: (json['messages'] as List<Map<String, Object?>>)
            .map((message) => MessageItemModel.fromLemmy(message))
            .toList(),
        nextPage: null,
      );

  factory MessageThreadModel.fromPiefed(Map<String, Object?> json) =>
      MessageThreadModel(
        id: json['threadId'] as int,
        participants: (json['participants'] as List<dynamic>)
            .map((participant) => DetailedUserModel.fromPiefed(
                {'person': participant as Map<String, Object?>}))
            .toList(),
        messages: (json['messages'] as List<Map<String, Object?>>)
            .reversed
            .map((message) => MessageItemModel.fromPiefed(message))
            .toList(),
        nextPage: null,
      );
}

@freezed
class MessageItemModel with _$MessageItemModel {
  const factory MessageItemModel({
    required int id,
    required UserModel sender,
    required String body,
    required DateTime createdAt,
    required bool isRead,
  }) = _MessageItemModel;

  factory MessageItemModel.fromMbin(Map<String, Object?> json) =>
      MessageItemModel(
        id: json['messageId'] as int,
        sender: UserModel.fromMbin(json['sender'] as Map<String, Object?>),
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['status'] as String == 'read',
      );

  factory MessageItemModel.fromLemmy(Map<String, Object?> json) {
    final pm = json['private_message'] as Map<String, Object?>;

    return MessageItemModel(
      id: pm['id'] as int,
      sender: UserModel.fromLemmy(json['creator'] as Map<String, Object?>),
      body: pm['content'] as String,
      createdAt: DateTime.parse(pm['published'] as String),
      isRead: pm['read'] as bool,
    );
  }

  factory MessageItemModel.fromPiefed(Map<String, Object?> json) {
    final pm = json['private_message'] as Map<String, Object?>;

    return MessageItemModel(
      id: pm['id'] as int,
      sender: UserModel.fromPiefed(json['creator'] as Map<String, Object?>),
      body: pm['content'] as String,
      createdAt: DateTime.parse(pm['published'] as String),
      isRead: pm['read'] as bool,
    );
  }
}
