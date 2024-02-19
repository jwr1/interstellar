import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/search.dart';
import 'package:interstellar/src/utils/utils.dart';

class KbinAPISearch {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPISearch(
    this.httpClient,
    this.instanceHost,
  );

  Future<SearchListModel> get({
    int? page,
    String? search,
  }) async {
    const path = '/api/search';

    final response = await httpClient.get(Uri.https(
      instanceHost,
      path,
      queryParams({'p': page?.toString(), 'q': search}),
    ));

    httpErrorHandler(response, message: 'Failed to load search');

    return SearchListModel.fromKbin(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
