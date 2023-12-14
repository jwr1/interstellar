import 'dart:convert';

import 'package:http/http.dart' as http;

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

Future<Domains> fetchDomains(String instanceHost,
    {int? page, String? search}) async {
  final response = await http.get(Uri.https(
      instanceHost, '/api/domains', {'p': page?.toString(), 'q': search}));

  if (response.statusCode == 200) {
    return Domains.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load domains');
  }
}

Future<Domain> fetchDomain(String instanceHost, int domainId) async {
  final response =
      await http.get(Uri.https(instanceHost, '/api/domain/$domainId'));

  if (response.statusCode == 200) {
    return Domain.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load domain');
  }
}
