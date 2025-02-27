import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/utils/utils.dart';

class APIMagazineModeration {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIMagazineModeration(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<MagazineBanListModel> listBans(
    int magazineId, {
    String? page,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId/bans';
        final query = queryParams({
          'p': page,
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load magazine bans');

        return MagazineBanListModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('List banned users not allowed on lemmy');
    }
  }

  Future<MagazineBanModel> createBan(
    int magazineId,
    int userId, {
    String? reason,
    DateTime? expiredAt,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId/ban/$userId';

        final response = await httpClient.post(
          Uri.https(server, path),
          body: jsonEncode({
            'reason': reason,
            'expiredAt': expiredAt?.toIso8601String(),
          }),
        );

        httpErrorHandler(response, message: 'Failed to send ban');

        return MagazineBanModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Ban update not implemented on Lemmy yet');
    }
  }

  Future<MagazineBanModel> removeBan(int magazineId, int userId) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId/ban/$userId';

        final response = await httpClient.delete(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send unban');

        return MagazineBanModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Ban update not implemented on Lemmy yet');
    }
  }

  Future<DetailedMagazineModel> create({
    required String name,
    required String title,
    required String description,
    required bool isAdult,
    required bool isPostingRestrictedToMods,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/new';

        final response = await httpClient.post(Uri.https(server, path),
            body: jsonEncode({
              'name': name,
              'title': title,
              'description': description,
              'isAdult': isAdult,
              'isPostingRestrictedToMods': isPostingRestrictedToMods,
            }));

        httpErrorHandler(response, message: 'Failed to create magazine');

        return DetailedMagazineModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/community';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'title': title,
            'description': description,
            'nsfw': isAdult,
            'posting_restricted_to_mods': isPostingRestrictedToMods,
          }),
        );

        httpErrorHandler(response, message: 'Failed to create magazine');

        return DetailedMagazineModel.fromLemmy(
            jsonDecode(response.body)['community_view']
                as Map<String, Object?>);
    }
  }

  Future<DetailedMagazineModel> edit(
    int magazineId, {
    required String title,
    required String description,
    required bool isAdult,
    required bool isPostingRestrictedToMods,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId';

        final response = await httpClient.put(Uri.https(server, path),
            body: jsonEncode({
              'title': title,
              'description': description,
              'isAdult': isAdult,
              'isPostingRestrictedToMods': isPostingRestrictedToMods,
            }));

        httpErrorHandler(response, message: 'Failed to edit magazine');

        return DetailedMagazineModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Magazine edit not implemented on Lemmy yet');
    }
  }

  Future<DetailedMagazineModel> updateModerator(
    int magazineId,
    int userId,
    bool state,
  ) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId/mod/$userId';

        final response = await (state
            ? httpClient.post(Uri.https(server, path))
            : httpClient.delete(Uri.https(server, path)));

        httpErrorHandler(response, message: 'Failed to send moderator update');

        return DetailedMagazineModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Moderator update not implemented on Lemmy yet');
    }
  }

  Future<void> removeIcon(int magazineId) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId/icon';

        final response = await httpClient.delete(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to remove icon');

        return;

      case ServerSoftware.lemmy:
        throw Exception('Remove icon not implemented on Lemmy yet');
    }
  }

  Future<void> delete(int magazineId) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/magazine/$magazineId';

        final response = await httpClient.delete(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to delete magazine');

        return;

      case ServerSoftware.lemmy:
        throw Exception('Magazine delete not implemented on Lemmy yet');
    }
  }
}
