import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/utils/utils.dart';

enum MagazinesSort { active, hot, newest }

Future<MagazineListModel> fetchMagazines(
  http.Client client,
  String instanceHost, {
  int? page,
  MagazinesSort? sort,
  String? search,
}) async {
  final response = await client.get(Uri.https(instanceHost, '/api/magazines',
      {'p': page?.toString(), 'sort': sort?.name, 'q': search}));

  httpErrorHandler(response, message: 'Failed to load magazines');

  return MagazineListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedMagazineModel> fetchMagazine(
  http.Client client,
  String instanceHost,
  int magazineId,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/magazine/$magazineId'));

  httpErrorHandler(response, message: 'Failed to load magazine');

  return DetailedMagazineModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedMagazineModel> putSubscribe(
  http.Client client,
  String instanceHost,
  int magazineId,
  bool state,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/magazine/$magazineId/${state ? 'subscribe' : 'unsubscribe'}',
  ));

  httpErrorHandler(response, message: 'Failed to send subscribe');

  return DetailedMagazineModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}
