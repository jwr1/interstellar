import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
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
