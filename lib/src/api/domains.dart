import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/utils/utils.dart';

Future<DomainListModel> fetchDomains(
  http.Client client,
  String instanceHost, {
  int? page,
  String? search,
}) async {
  final response = await client.get(Uri.https(
      instanceHost, '/api/domains', {'p': page?.toString(), 'q': search}));

  httpErrorHandler(response, message: 'Failed to load domains');

  return DomainListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DomainModel> fetchDomain(
  http.Client client,
  String instanceHost,
  int domainId,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/domain/$domainId'));

  httpErrorHandler(response, message: 'Failed to load domain');

  return DomainModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DomainModel> putSubscribe(
  http.Client client,
  String instanceHost,
  int domainId,
  bool state,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/domain/$domainId/${state ? 'subscribe' : 'unsubscribe'}',
  ));

  httpErrorHandler(response, message: 'Failed to send subscribe');

  return DomainModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}
