import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/search.dart';

class APISearch {
  final ServerClient client;

  APISearch(this.client);

  Future<SearchListModel> get({
    String? page,
    String? search,
  }) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        const path = '/search';

        final response = await client.send(
          HttpMethod.get,
          path,
          queryParams: {'p': page, 'q': search},
        );

        return SearchListModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        const path = '/search';
        final query = {
          'q': search,
          'page': page ?? '1',
          'type_': 'All',
          'listing_type': 'All'
        };

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        final json = response.bodyJson;
        String? nextPage;
        if ((json['comments'] as List<dynamic>).isNotEmpty ||
            (json['posts'] as List<dynamic>).isNotEmpty ||
            (json['communities'] as List<dynamic>).isNotEmpty ||
            (json['users'] as List<dynamic>).isNotEmpty) {
          nextPage = (int.parse(page ?? '1') + 1).toString();
        }

        json['next_page'] = nextPage;

        return SearchListModel.fromLemmy(json);

      case ServerSoftware.piefed:
        const path = '/search';
        final query = {
          'q': search,
          'page': page ?? '1',
          'type_': 'All',
          'listing_type': 'All'
        };

        final response =
            await client.send(HttpMethod.get, path, queryParams: query);

        final json = response.bodyJson;
        String? nextPage;
        if ((json['comments'] as List<dynamic>).isNotEmpty ||
            (json['posts'] as List<dynamic>).isNotEmpty ||
            (json['communities'] as List<dynamic>).isNotEmpty ||
            (json['users'] as List<dynamic>).isNotEmpty) {
          nextPage = (int.parse(page ?? '1') + 1).toString();
        }

        json['next_page'] = nextPage;

        return SearchListModel.fromPiefed(json);
    }
  }
}
