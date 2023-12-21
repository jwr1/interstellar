import 'dart:convert';

import 'package:http/http.dart' as http;

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

Future<Users> fetchUsers(String instanceHost, {int? page}) async {
  final response = await http
      .get(Uri.https(instanceHost, '/api/users', {'p': page?.toString()}));

  if (response.statusCode == 200) {
    return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load magazines');
  }
}

Future<DetailedUser> fetchUser(String instanceHost, int userId) async {
  final response =
      await http.get(Uri.https(instanceHost, '/api/users/$userId'));

  if (response.statusCode == 200) {
    return DetailedUser.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load user');
  }
}

Future<DetailedUser> fetchMe(http.Client client, String instanceHost) async {
  final response = await client.get(Uri.https(instanceHost, '/api/users/me'));

  if (response.statusCode == 200) {
    return DetailedUser.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load user');
  }
}
