import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/old/message.dart';
import 'package:interstellar/src/utils/utils.dart';

class KbinAPIMessages {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPIMessages(
    this.httpClient,
    this.instanceHost,
  );

  Future<MessageListModel> list({
    int? page,
  }) async {
    const path = '/api/messages';
    final query = queryParams({'p': page?.toString()});

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load messages');

    return MessageListModel.fromJson(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<MessageThreadModel> create(
    int userId,
    String body,
  ) async {
    final path = '/api/users/$userId/message';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to send message');

    return MessageThreadModel.fromJson(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<MessageThreadModel> postThreadReply(
    int threadId,
    String body,
  ) async {
    final path = '/api/messages/thread/$threadId/reply';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to send message');

    return MessageThreadModel.fromJson(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
