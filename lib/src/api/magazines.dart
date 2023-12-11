import 'dart:convert';

import 'package:http/http.dart' as http;

import './shared.dart';

class Magazines {
  late List<Magazine> items;
  late Pagination pagination;

  Magazines({required this.items, required this.pagination});

  Magazines.fromJson(Map<String, dynamic> json) {
    items = <Magazine>[];
    json['items'].forEach((v) {
      items.add(Magazine.fromJson(v));
    });

    pagination = Pagination.fromJson(json['pagination']);
  }
}

class Magazine {
  late Moderator owner;
  Image? icon;
  late String name;
  late String title;
  String? description;
  String? rules;
  late int subscriptionsCount;
  late int entryCount;
  late int entryCommentCount;
  late int postCount;
  late int postCommentCount;
  late bool isAdult;
  bool? isUserSubscribed;
  bool? isBlockedByUser;
  List<String>? tags;
  List<Moderator>? moderators;
  String? apId;
  String? apProfileId;
  late int magazineId;

  Magazine(
      {required this.owner,
      this.icon,
      required this.name,
      required this.title,
      this.description,
      this.rules,
      required this.subscriptionsCount,
      required this.entryCount,
      required this.entryCommentCount,
      required this.postCount,
      required this.postCommentCount,
      required this.isAdult,
      this.isUserSubscribed,
      this.isBlockedByUser,
      this.tags,
      this.moderators,
      this.apId,
      this.apProfileId,
      required this.magazineId});

  Magazine.fromJson(Map<String, dynamic> json) {
    owner = Moderator.fromJson(json['owner']);
    icon = json['icon'] != null ? Image.fromJson(json['icon']) : null;
    name = json['name'];
    title = json['title'];
    description = json['description'];
    rules = json['rules'];
    subscriptionsCount = json['subscriptionsCount'];
    entryCount = json['entryCount'];
    entryCommentCount = json['entryCommentCount'];
    postCount = json['postCount'];
    postCommentCount = json['postCommentCount'];
    isAdult = json['isAdult'];
    isUserSubscribed = json['isUserSubscribed'];
    isBlockedByUser = json['isBlockedByUser'];
    tags = json['tags']?.cast<String>();
    if (json['moderators'] != null) {
      moderators = <Moderator>[];
      json['moderators'].forEach((v) {
        moderators!.add(Moderator.fromJson(v));
      });
    }
    apId = json['apId'];
    apProfileId = json['apProfileId'];
    magazineId = json['magazineId'];
  }
}

class Moderator {
  late int magazineId;
  late int userId;
  Image? avatar;
  late String username;
  String? apId;

  Moderator(
      {required this.magazineId,
      required this.userId,
      this.avatar,
      required this.username,
      this.apId});

  Moderator.fromJson(Map<String, dynamic> json) {
    magazineId = json['magazineId'];
    userId = json['userId'];
    avatar = json['avatar'] != null ? Image.fromJson(json['avatar']) : null;
    username = json['username'];
    apId = json['apId'];
  }
}

enum MagazinesSort { active, hot, newest }

Future<Magazines> fetchMagazines(String instanceHost,
    {int? page, MagazinesSort? sort, String? search}) async {
  final response = await http.get(Uri.https(instanceHost, '/api/magazines',
      {'p': page?.toString(), 'sort': sort?.name, 'q': search}));

  if (response.statusCode == 200) {
    return Magazines.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load magazines');
  }
}
