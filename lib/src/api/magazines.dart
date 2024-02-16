import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/utils/utils.dart';

enum KbinAPIMagazinesFilter { all, subscribed, moderated, blocked }

enum KbinAPIMagazinesSort { active, hot, newest }

class KbinAPIMagazines {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPIMagazines(
    this.httpClient,
    this.instanceHost,
  );

  Future<MagazineListModel> list({
    int? page,
    KbinAPIMagazinesFilter? filter,
    KbinAPIMagazinesSort? sort,
    String? search,
  }) async {
    final path = (filter == null || filter == KbinAPIMagazinesFilter.all)
        ? '/api/magazines'
        : '/api/magazines/${filter.name}';
    final query = queryParams(
      (filter == null || filter == KbinAPIMagazinesFilter.all)
          ? {'p': page?.toString(), 'sort': sort?.name, 'q': search}
          : {'p': page?.toString()},
    );

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load magazines');

    return MagazineListModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DetailedMagazineModel> get(int magazineId) async {
    final path = '/api/magazine/$magazineId';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load magazine');

    return DetailedMagazineModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DetailedMagazineModel> getByName(String magazineName) async {
    final path = '/api/magazine/name/$magazineName';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load magazine');

    return DetailedMagazineModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DetailedMagazineModel> putSubscribe(int magazineId, bool state) async {
    final path =
        '/api/magazine/$magazineId/${state ? 'subscribe' : 'unsubscribe'}';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send subscribe');

    return DetailedMagazineModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DetailedMagazineModel> putBlock(int magazineId, bool state) async {
    final path = '/api/magazine/$magazineId/${state ? 'block' : 'unblock'}';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send block');

    return DetailedMagazineModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
