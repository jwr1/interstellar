import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/utils/utils.dart';

Future<MessageListModel> fetchMessages(
  http.Client client,
  String instanceHost, {
  int? page,
}) async {
  final response = await client
      .get(Uri.https(instanceHost, '/api/messages', {'p': page?.toString()}));

  httpErrorHandler(response, message: 'Failed to load messages');

  return MessageListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<MessageThreadModel> postMessage(
  http.Client client,
  String instanceHost,
  int userId,
  String body,
) async {
  final response = await client.post(
    Uri.https(instanceHost, '/api/users/$userId/message'),
    body: jsonEncode({'body': body}),
  );

  httpErrorHandler(response, message: 'Failed to send message');

  return MessageThreadModel.fromJson(
      jsonDecode(response.body) as Map<String, Object?>);
}

Future<MessageThreadModel> postMessageThreadReply(
  http.Client client,
  String instanceHost,
  int threadId,
  String body,
) async {
  final response = await client.post(
    Uri.https(instanceHost, '/api/messages/thread/$threadId/reply'),
    body: jsonEncode({'body': body}),
  );

  httpErrorHandler(response, message: 'Failed to send message');

  return MessageThreadModel.fromJson(
      jsonDecode(response.body) as Map<String, Object?>);
}
