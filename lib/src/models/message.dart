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
    int myUserId, {
    int? filterByThreadId,
  }) {
    Map<int, Map<String, Object?>> threads = {};

    for (final message in json['private_messages'] as List<dynamic>) {
      final creator = (message)['creator'] as Map<String, Object?>;
      final recipient = (message)['recipient'] as Map<String, Object?>;

      // Use the userId of the other person as the threadId
      final threadId = (creator['id'] as int) == myUserId
          ? recipient['id'] as int
          : creator['id'] as int;

      if (filterByThreadId != null && filterByThreadId != threadId) continue;

      if (threads[threadId] == null) {
        threads[threadId] = {
          'threadId': threadId,
          'messages': <Map<String, Object?>>[],
          'participants': [creator, recipient],
          'next_page': json['next_page'] as String?
        };
      }

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
    int myUserId, {
    int? filterByThreadId,
  }) {
    Map<int, Map<String, Object?>> threads = {};

    for (final message in json['private_messages'] as List<dynamic>) {
      final creator = (message)['creator'] as Map<String, Object?>;
      final recipient = (message)['recipient'] as Map<String, Object?>;

      // Use the userId of the other person as the threadId
      final threadId = (creator['id'] as int) == myUserId
          ? recipient['id'] as int
          : creator['id'] as int;

      if (filterByThreadId != null && filterByThreadId != threadId) continue;

      if (threads[threadId] == null) {
        threads[threadId] = {
          'threadId': threadId,
          'messages': <Map<String, Object?>>[],
          'participants': [creator, recipient],
          'next_page': json['next_page'] as String?
        };
      }

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
    required List<MessageThreadItemModel> messages,
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
            .map((message) => MessageThreadItemModel.fromMbin(
                message as Map<String, Object?>))
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
            .map((message) => MessageThreadItemModel.fromLemmy(message))
            .toList(),
        nextPage: json['next_page'] as String?,
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
            .map((message) => MessageThreadItemModel.fromPiefed(message))
            .toList(),
        nextPage: json['next_page'] as String?,
      );
}

@freezed
class MessageThreadItemModel with _$MessageThreadItemModel {
  const factory MessageThreadItemModel({
    required int id,
    required UserModel sender,
    required String body,
    required DateTime createdAt,
    required bool isRead,
  }) = _MessageThreadItemModel;

  factory MessageThreadItemModel.fromMbin(Map<String, Object?> json) =>
      MessageThreadItemModel(
        id: json['messageId'] as int,
        sender: UserModel.fromMbin(json['sender'] as Map<String, Object?>),
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['status'] as String == 'read',
      );

  factory MessageThreadItemModel.fromLemmy(Map<String, Object?> json) {
    final pm = json['private_message'] as Map<String, Object?>;

    return MessageThreadItemModel(
      id: pm['id'] as int,
      sender: UserModel.fromLemmy(json['creator'] as Map<String, Object?>),
      body: pm['content'] as String,
      createdAt: DateTime.parse(pm['published'] as String),
      isRead: pm['read'] as bool,
    );
  }

  factory MessageThreadItemModel.fromPiefed(Map<String, Object?> json) {
    final pm = json['private_message'] as Map<String, Object?>;

    return MessageThreadItemModel(
      id: pm['id'] as int,
      sender: UserModel.fromPiefed(json['creator'] as Map<String, Object?>),
      body: pm['content'] as String,
      createdAt: DateTime.parse(pm['published'] as String),
      isRead: pm['read'] as bool,
    );
  }
}
