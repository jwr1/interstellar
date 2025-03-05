
import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/models/message.dart';

class MbinAPIMessages {
  final ServerClient client;

  MbinAPIMessages(this.client);

  Future<MessageListModel> list({
    String? page,
  }) async {
    const path = '/messages';
    final query = {'p': page};

    final response =
        await client.send(HttpMethod.get, path, queryParams: query);

    return MessageListModel.fromMbin(response.bodyJson);
  }

  Future<MessageThreadModel> create(
    int userId,
    String body,
  ) async {
    final path = '/users/$userId/message';

    final response = await client.send(
      HttpMethod.post,
      path,
      body: {'body': body},
    );

    return MessageThreadModel.fromMbin(response.bodyJson);
  }

  Future<MessageThreadModel> postThreadReply(
    int threadId,
    String body,
  ) async {
    final path = '/messages/thread/$threadId/reply';

    final response = await client.send(
      HttpMethod.post,
      path,
      body: {'body': body},
    );

    return MessageThreadModel.fromMbin(response.bodyJson);
  }
}
