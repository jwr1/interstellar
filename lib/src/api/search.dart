import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/search.dart';
import 'package:interstellar/src/utils/utils.dart';

class APISearch {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APISearch(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<SearchListModel> get({
    String? page,
    String? search,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        const path = '/api/search';

        final response = await httpClient.get(Uri.https(
          server,
          path,
          queryParams({'p': page, 'q': search}),
        ));

        httpErrorHandler(response, message: 'Failed to load search');

        return SearchListModel.fromMbin(
            jsonDecode(response.body) as Map<String, dynamic>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/search';
        final query = queryParams({
          'q': search,
          'page': page ?? '1',
          'type_': 'All',
          'listing_type': 'All'
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load search');

        final json = jsonDecode(response.body) as Map<String, Object?>;
        String? nextPage;
        if ((json['comments'] as List<dynamic>).isNotEmpty ||
            (json['posts'] as List<dynamic>).isNotEmpty ||
            (json['communities'] as List<dynamic>).isNotEmpty ||
            (json['users'] as List<dynamic>).isNotEmpty) {
          nextPage = (int.parse(page ?? '1') + 1).toString();
        }

        json['next_page'] = nextPage;

        return SearchListModel.fromLemmy(json);
    }
  }
}
