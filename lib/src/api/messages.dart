import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';

class MbinAPIMessages {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  MbinAPIMessages(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<MessageListModel> list({
    String? page,
  }) async {
    const path = '/api/messages';
    final query = queryParams({'p': page});

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load messages');

    return MessageListModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<MessageThreadModel> create(
    int userId,
    String body,
  ) async {
    final path = '/api/users/$userId/message';

    final response = await httpClient.post(
      Uri.https(server, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to send message');

    return MessageThreadModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<MessageThreadModel> postThreadReply(
    int threadId,
    String body,
  ) async {
    final path = '/api/messages/thread/$threadId/reply';

    final response = await httpClient.post(
      Uri.https(server, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to send message');

    return MessageThreadModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
