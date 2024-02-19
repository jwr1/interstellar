import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

enum UsersFilter { all, followed, followers, blocked }

class KbinAPIUsers {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPIUsers(
    this.httpClient,
    this.instanceHost,
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

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load users');

    return DetailedUserListModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> get(int userId) async {
    final path = '/api/users/$userId';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load user');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> getByName(String username) async {
    final path = '/api/users/name/$username';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load user');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> getMe() async {
    const path = '/api/users/me';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load user');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> putFollow(
    int userId,
    bool state,
  ) async {
    final path = '/api/users/$userId/${state ? 'follow' : 'unfollow'}';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send follow');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> updateProfile(String about) async {
    const path = '/api/users/profile';

    final response = await httpClient.put(Uri.https(instanceHost, path),
        body: jsonEncode({'about': about}));

    httpErrorHandler(response, message: 'Failed to update profile');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> putBlock(
    int userId,
    bool state,
  ) async {
    final path = '/api/users/$userId/${state ? 'block' : 'unblock'}';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send block');

    return DetailedUserModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<DetailedUserModel> updateAvatar(XFile image) async {
    const path = '/api/users/avatar';

    var request = http.MultipartRequest('POST', Uri.https(instanceHost, path));
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

    var request = http.MultipartRequest('POST', Uri.https(instanceHost, path));
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
}
