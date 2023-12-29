import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/utils/utils.dart';

import 'shared.dart';

class Posts {
  late List<PostItem> items;
  late Pagination pagination;

  Posts({required this.items, required this.pagination});

  Posts.fromJson(Map<String, dynamic> json) {
    items = <PostItem>[];
    json['items'].forEach((v) {
      items.add(PostItem.fromJson(v));
    });

    pagination = Pagination.fromJson(json['pagination']);
  }
}

class PostItem {
  late int postId;
  late Magazine magazine;
  late User user;
  Image? image;
  String? body;
  late String lang;
  late int numComments;
  late int uv;
  late int dv;
  late int favourites;
  bool? isFavourited;
  int? userVote;
  late bool isAdult;
  late bool isPinned;
  late DateTime createdAt;
  DateTime? editedAt;
  late DateTime lastActive;
  late String slug;
  String? apId;
  //TODO: tags
  //TODO: mentions
  late String visibility;

  PostItem(
      {required this.postId,
      required this.magazine,
      required this.user,
      this.image,
      this.body,
      required this.lang,
      required this.numComments,
      required this.uv,
      required this.dv,
      required this.favourites,
      this.isFavourited,
      this.userVote,
      required this.isAdult,
      required this.isPinned,
      required this.createdAt,
      this.editedAt,
      required this.lastActive,
      required this.slug,
      this.apId,
      required this.visibility});

  PostItem.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    magazine = Magazine.fromJson(json['magazine']);
    user = User.fromJson(json['user']);
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    body = json['body'];
    lang = json['lang'];
    numComments = json['comments'];
    uv = json['uv'];
    dv = json['dv'];
    favourites = json['favourites'];
    isFavourited = json['isFavourited'];
    userVote = json['userVote'];
    isAdult = json['isAdult'];
    isPinned = json['isPinned'];
    createdAt = DateTime.parse(json['createdAt']);
    editedAt =
        json['editedAt'] == null ? null : DateTime.parse(json['editedAt']);
    lastActive = DateTime.parse(json['lastActive']);
    slug = json['slug'];
    apId = json['apId'];
    visibility = json['visibility'];
  }
}

Future<Posts> fetchPosts(
  http.Client client,
  String instanceHost,
  ContentSource source, {
  int? page,
  ContentSort? sort,
}) async {
  if (source.getPostsPath() == null) {
    throw Exception('Failed to load posts');
  }

  final response = await client.get(Uri.https(
      instanceHost,
      source.getPostsPath()!,
      removeNulls({'p': page?.toString(), 'sort': sort?.name})));

  httpErrorHandler(response, message: 'Failed to load posts');

  return Posts.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostItem> putVote(
  http.Client client,
  String instanceHost,
  int postID,
  int choice,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/post/$postID/vote/$choice',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return PostItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostItem> putFavorite(
  http.Client client,
  String instanceHost,
  int postID,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/post/$postID/favourite',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return PostItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}
