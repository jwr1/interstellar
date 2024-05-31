import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';

enum MbinAPIDomainsFilter { all, subscribed, blocked }

class MbinAPIDomains {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  MbinAPIDomains(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<DomainListModel> list({
    String? page,
    MbinAPIDomainsFilter? filter,
    String? search,
  }) async {
    final path = (filter == null || filter == MbinAPIDomainsFilter.all)
        ? '/api/domains'
        : '/api/domains/${filter.name}';
    final query = queryParams(
        (filter == null || filter == MbinAPIDomainsFilter.all)
            ? {'p': page, 'q': search}
            : {'p': page});

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load domains');

    return DomainListModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DomainModel> get(int domainId) async {
    final path = '/api/domain/$domainId';

    final response = await httpClient.get(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to load domain');

    return DomainModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DomainModel> putSubscribe(int domainId, bool state) async {
    final path = '/api/domain/$domainId/${state ? 'subscribe' : 'unsubscribe'}';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to send subscribe');

    return DomainModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DomainModel> putBlock(int domainId, bool state) async {
    final path = '/api/domain/$domainId/${state ? 'block' : 'unblock'}';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to send block');

    return DomainModel.fromMbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
