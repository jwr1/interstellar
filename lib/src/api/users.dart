import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

enum UsersFilter { all, followed, followers, blocked }

Future<UserListModel> fetchUsers(
  http.Client client,
  String instanceHost, {
  int? page,
  UsersFilter? filter,
}) async {
  final response = (filter == null || filter == UsersFilter.all)
      ? await client.get(Uri.https(instanceHost, '/api/users', {
          'p': page?.toString(),
        }))
      : await client.get(Uri.https(
          instanceHost, '/api/users/${filter.name}', {'p': page?.toString()}));

  httpErrorHandler(response, message: 'Failed to load users');

  return UserListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> fetchUser(
  http.Client client,
  String instanceHost,
  int userId,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/users/$userId'));

  httpErrorHandler(response, message: 'Failed to load user');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> fetchUserByName(
  http.Client client,
  String instanceHost,
  String username,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/users/name/$username'));

  httpErrorHandler(response, message: 'Failed to load user');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> fetchMe(
  http.Client client,
  String instanceHost,
) async {
  final response = await client.get(Uri.https(instanceHost, '/api/users/me'));

  httpErrorHandler(response, message: 'Failed to load user');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> putFollow(
  http.Client client,
  String instanceHost,
  int userId,
  bool state,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/users/$userId/${state ? 'follow' : 'unfollow'}',
  ));

  httpErrorHandler(response, message: 'Failed to send follow');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> updateProfile(
  http.Client client,
  String instanceHost,
  String about
) async {
  final response = await client.put(
    Uri.https(instanceHost, '/api/users/profile'),
    body: jsonEncode({'about': about})
  );

  httpErrorHandler(response, message: 'Failed to update profile');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> putBlock(
  http.Client client,
  String instanceHost,
  int userId,
  bool state,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/users/$userId/${state ? 'block' : 'unblock'}',
  ));

  httpErrorHandler(response, message: 'Failed to send block');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> updateAvatar(
  http.Client client,
  String instanceHost,
  XFile image
) async {
  var request = http.MultipartRequest(
      'POST', Uri.https(instanceHost, '/api/users/avatar'));
  var multipartFile = http.MultipartFile.fromBytes(
    'uploadImage',
    await image.readAsBytes(),
    filename: basename(image.path),
    contentType: MediaType.parse(lookupMimeType(image.path)!),
  );
  request.files.add(multipartFile);
  var response = await http.Response.fromStream(await client.send(request));

  httpErrorHandler(response, message: 'Failed to update profile');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUserModel> updateCover(
  http.Client client,
  String instanceHost,
  XFile image
) async {
  var request = http.MultipartRequest(
      'POST', Uri.https(instanceHost, '/api/users/cover'));
  var multipartFile = http.MultipartFile.fromBytes(
    'uploadImage',
    await image.readAsBytes(),
    filename: basename(image.path),
    contentType: MediaType.parse(lookupMimeType(image.path)!),
  );
  request.files.add(multipartFile);
  var response = await http.Response.fromStream(await client.send(request));

  httpErrorHandler(response, message: 'Failed to update profile');

  return DetailedUserModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}
