import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/utils/utils.dart';

import './shared.dart';

class Users {
  late List<DetailedUser> items;
  late Pagination pagination;

  Users({required this.items, required this.pagination});

  Users.fromJson(Map<String, dynamic> json) {
    items = <DetailedUser>[];
    json['items'].forEach((v) {
      items.add(DetailedUser.fromJson(v));
    });

    pagination = Pagination.fromJson(json['pagination']);
  }
}

class DetailedUser {
  Image? avatar;
  Image? cover;
  late String username;
  late int followersCount;
  String? about;
  late DateTime createdAt;
  String? apProfileId;
  String? apId;
  late bool isBot;
  bool? isFollowedByUser;
  bool? isFollowerOfUser;
  bool? isBlockedByUser;
  late int userId;

  DetailedUser(
      {this.avatar,
      this.cover,
      required this.username,
      required this.followersCount,
      this.about,
      required this.createdAt,
      this.apProfileId,
      this.apId,
      required this.isBot,
      this.isFollowedByUser,
      this.isFollowerOfUser,
      this.isBlockedByUser,
      required this.userId});

  DetailedUser.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'] != null ? Image.fromJson(json['avatar']) : null;
    cover = json['cover'] != null ? Image.fromJson(json['cover']) : null;
    username = json['username'];
    followersCount = json['followersCount'];
    about = json['about'];
    createdAt = DateTime.parse(json['createdAt']);
    apProfileId = json['apProfileId'];
    apId = json['apId'];
    isBot = json['isBot'];
    isFollowedByUser = json['isFollowedByUser'];
    isFollowerOfUser = json['isFollowerOfUser'];
    isBlockedByUser = json['isBlockedByUser'];
    userId = json['userId'];
  }
}

Future<Users> fetchUsers(
  http.Client client,
  String instanceHost, {
  int? page,
}) async {
  final response = await client.get(Uri.https(instanceHost, '/api/users', {
    'p': page?.toString(),
  }));

  httpErrorHandler(response, message: 'Failed to load users');

  return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUser> fetchUser(
  http.Client client,
  String instanceHost,
  int userId,
) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/users/$userId'));

  httpErrorHandler(response, message: 'Failed to load user');

  return DetailedUser.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUser> fetchMe(
  http.Client client,
  String instanceHost,
) async {
  final response = await client.get(Uri.https(instanceHost, '/api/users/me'));

  httpErrorHandler(response, message: 'Failed to load user');

  return DetailedUser.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<DetailedUser> putFollow(
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

  return DetailedUser.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}
