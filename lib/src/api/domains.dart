import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/utils/utils.dart';

import './shared.dart';

class Domains {
  late List<Domain> items;
  late Pagination pagination;

  Domains({required this.items, required this.pagination});

  Domains.fromJson(Map<String, dynamic> json) {
    items = <Domain>[];
    json['items'].forEach((v) {
      items.add(Domain.fromJson(v));
    });

    pagination = Pagination.fromJson(json['pagination']);
  }
}

Future<Domains> fetchDomains(
  http.Client client,
  String instanceHost, {
  int? page,
  String? search,
}) async {
  final response = await client.get(Uri.https(
      instanceHost, '/api/domains', {'p': page?.toString(), 'q': search}));

  httpErrorHandler(response, message: 'Failed to load domains');

  return Domains.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<Domain> fetchDomain(
  http.Client client,
  String instanceHost,
  int domainId,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/domain/$domainId'));

  httpErrorHandler(response, message: 'Failed to load domain');

  return Domain.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<Domain> putSubscribe(
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

  return Domain.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}
