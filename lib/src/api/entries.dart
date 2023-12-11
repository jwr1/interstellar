import 'dart:convert';

import 'package:http/http.dart' as http;

import 'shared.dart';

class Entries {
  late List<EntryItem> items;
  late Pagination pagination;

  Entries({required this.items, required this.pagination});

  Entries.fromJson(Map<String, dynamic> json) {
    items = <EntryItem>[];
    json['items'].forEach((v) {
      items.add(EntryItem.fromJson(v));
    });

    pagination = Pagination.fromJson(json['pagination']);
  }
}

class EntryItem {
  late int entryId;
  late Magazine magazine;
  late User user;
  late EntryDomain domain;
  late String title;
  String? url;
  Image? image;
  String? body;
  late String lang;
  late int numComments;
  late int uv;
  late int dv;
  late int favourites;
  bool? isFavourited;
  int? userVote;
  late bool isOc;
  late bool isAdult;
  late bool isPinned;
  late DateTime createdAt;
  DateTime? editedAt;
  late DateTime lastActive;
  late String type;
  late String slug;
  String? apId;
  late String visibility;

  EntryItem(
      {required this.entryId,
      required this.magazine,
      required this.user,
      required this.domain,
      required this.title,
      this.url,
      this.image,
      this.body,
      required this.lang,
      required this.numComments,
      required this.uv,
      required this.dv,
      required this.favourites,
      this.isFavourited,
      this.userVote,
      required this.isOc,
      required this.isAdult,
      required this.isPinned,
      required this.createdAt,
      this.editedAt,
      required this.lastActive,
      required this.type,
      required this.slug,
      this.apId,
      required this.visibility});

  EntryItem.fromJson(Map<String, dynamic> json) {
    entryId = json['entryId'];
    magazine = Magazine.fromJson(json['magazine']);
    user = User.fromJson(json['user']);
    domain = EntryDomain.fromJson(json['domain']);
    title = json['title'];
    url = json['url'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    body = json['body'];
    lang = json['lang'];
    numComments = json['numComments'];
    uv = json['uv'];
    dv = json['dv'];
    favourites = json['favourites'];
    isFavourited = json['isFavourited'];
    userVote = json['userVote'];
    isOc = json['isOc'];
    isAdult = json['isAdult'];
    isPinned = json['isPinned'];
    createdAt = DateTime.parse(json['createdAt']);
    editedAt =
        json['editedAt'] == null ? null : DateTime.parse(json['editedAt']);
    lastActive = DateTime.parse(json['lastActive']);
    type = json['type'];
    slug = json['slug'];
    apId = json['apId'];
    visibility = json['visibility'];
  }
}

class EntryDomain {
  late String name;
  late int entryCount;
  late int subscriptionsCount;
  bool? isUserSubscribed;
  bool? isBlockedByUser;
  late int domainId;

  EntryDomain(
      {required this.name,
      required this.entryCount,
      required this.subscriptionsCount,
      this.isUserSubscribed,
      this.isBlockedByUser,
      required this.domainId});

  EntryDomain.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    entryCount = json['entryCount'];
    subscriptionsCount = json['subscriptionsCount'];
    isUserSubscribed = json['isUserSubscribed'];
    isBlockedByUser = json['isBlockedByUser'];
    domainId = json['domainId'];
  }
}

enum EntriesSort { active, hot, newest, oldest, top, commented }

Future<Entries> fetchEntries(String instanceHost,
    {int? page, EntriesSort? sort}) async {
  final response = await http.get(Uri.https(instanceHost, '/api/entries',
      {'p': page?.toString(), 'sort': sort?.name}));

  if (response.statusCode == 200) {
    return Entries.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load entries');
  }
}
