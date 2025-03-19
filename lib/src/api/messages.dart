
import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/message.dart';

class APIMessages {
  final ServerClient client;

  APIMessages(this.client);

  Future<MessageListModel> list({
    String? page,
    int id = 0,
  }) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        const path = '/messages';
        final query = {'p': page};

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        return MessageListModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        const path = '/private_message/list';
        final query = {
          'unread_only': 'false',
          'page': page,
          'limit': '20',
        };

        final response =
        await client.send(HttpMethod.get, path, queryParams: query);

        final json = response.bodyJson;

        json['next_page'] = page;

        return MessageListModel.fromLemmy(json, id, 20);

      case ServerSoftware.piefed:
        const path = '/private_message/list';
        final query = {
          'unread_only': 'false',
          'page': page,
          'limit': '20',
        };

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        final json = response.bodyJson;

        json['next_page'] = page;

        return MessageListModel.fromPiefed(json, id, 20);
    }
  }

  Future<MessageThreadModel> create(
    int userId,
    String body,
  ) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = '/users/$userId/message';

        final response = await client.send(
          HttpMethod.post,
          path,
          body: {'body': body},
        );

        return MessageThreadModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<MessageThreadModel> postThreadReply(
    int threadId,
    String body,
  ) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = '/messages/thread/$threadId/reply';

        final response = await client.send(
          HttpMethod.post,
          path,
          body: {'body': body},
        );

        return MessageThreadModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }
}
