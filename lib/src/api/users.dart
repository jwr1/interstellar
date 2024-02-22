import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

enum UsersFilter { all, followed, followers, blocked }

class APIUsers {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIUsers(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<DetailedUserListModel> list({
    int? page,
    UsersFilter? filter,
  }) async {
    final path = (filter == null || filter == UsersFilter.all)
        ? '/api/users'
        : '/api/users/${filter.name}';
    final query = queryParams({
      'p': page?.toString(),
    });

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load users');

    return DetailedUserListModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> get(int userId) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/users/$userId';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load user');

        return DetailedUserModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);
      case ServerSoftware.lemmy:
        const path = '/api/v3/user';
        final query = queryParams({
          'person_id': userId.toString()
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: "Failed to load user");

        return DetailedUserModel.fromLemmy(
          jsonDecode(response.body) as Map<String, Object?>);
    }
  }

  Future<DetailedUserModel> getByName(String username) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/users/name/$username';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load user');

        return DetailedUserModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);
      case ServerSoftware.lemmy:
        const path = '/api/v3/user';
        final query = queryParams({
          'username': username
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: "Failed to load user");

        return DetailedUserModel.fromLemmy(
            jsonDecode(response.body) as Map<String, Object?>);
    }
  }

  Future<UserModel> getMe() async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        const path = '/api/users/me';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load user');

        return UserModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/site';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load site info');

        return UserModel.fromLemmy((jsonDecode(response.body)['my_user']
            ['local_user_view']['person']) as Map<String, Object?>);
    }
  }

  Future<DetailedUserModel> putFollow(
    int userId,
    bool state,
  ) async {
    final path = '/api/users/$userId/${state ? 'follow' : 'unfollow'}';

    final response = await httpClient.put(Uri.https(server, path));

    httpErrorHandler(response, message: 'Failed to send follow');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel?> updateProfile(String about) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        const path = '/api/users/profile';

        final response = await httpClient.put(Uri.https(server, path),
            body: jsonEncode({'about': about}));

        httpErrorHandler(response, message: 'Failed to update profile');

        return DetailedUserModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);
      case ServerSoftware.lemmy:
        const path = '/api/v3/user/save_user_settings';

        final response = await httpClient.put(Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'bio': about}));

        httpErrorHandler(response, message: "Failed to load user");

        return null;
    }
  }

  Future<DetailedUserModel> putBlock(
    int userId,
    bool state,
  ) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:

        final path = '/api/users/$userId/${state ? 'block' : 'unblock'}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send block');

        return DetailedUserModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);
      case ServerSoftware.lemmy:
        const path = '/api/v3/user/block';

        final response = await httpClient.post(Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'person_id': userId,
            'block': state
          }));

        httpErrorHandler(response, message: "Failed to send block");

        return DetailedUserModel.fromLemmy(
            jsonDecode(response.body) as Map<String, Object?>);
    }
  }

  Future<DetailedUserModel> updateAvatar(XFile image) async {
    const path = '/api/users/avatar';

    var request = http.MultipartRequest('POST', Uri.https(server, path));
    var multipartFile = http.MultipartFile.fromBytes(
      'uploadImage',
      await image.readAsBytes(),
      filename: basename(image.path),
      contentType: MediaType.parse(lookupMimeType(image.path)!),
    );
    request.files.add(multipartFile);
    var response =
        await http.Response.fromStream(await httpClient.send(request));

    httpErrorHandler(response, message: 'Failed to update profile');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> updateCover(XFile image) async {
    const path = '/api/users/cover';

    var request = http.MultipartRequest('POST', Uri.https(server, path));
    var multipartFile = http.MultipartFile.fromBytes(
      'uploadImage',
      await image.readAsBytes(),
      filename: basename(image.path),
      contentType: MediaType.parse(lookupMimeType(image.path)!),
    );
    request.files.add(multipartFile);
    var response =
        await http.Response.fromStream(await httpClient.send(request));

    httpErrorHandler(response, message: 'Failed to update profile');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserListModel> listFollowers(
    int userId, {
    String? page
  }) async {
    final path = '/api/users/$userId/followers';
    final query = queryParams({
      'p': page,
    });

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load followers');

    return DetailedUserListModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserListModel> listFollowing(
      int userId, {
        String? page
      }) async {
    final path = '/api/users/$userId/followed';
    final query = queryParams({
      'p': page,
    });

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load following');

    return DetailedUserListModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
