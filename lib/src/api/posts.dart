import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/utils/utils.dart';

Future<PostListModel> fetchPosts(
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

  return PostListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostModel> putVote(
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

  return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostModel> putFavorite(
  http.Client client,
  String instanceHost,
  int postID,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/post/$postID/favourite',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostModel> editPost(http.Client client, String instanceHost, int postID,
    String body, String lang, bool isAdult) async {
  final response = await client.put(
      Uri.https(instanceHost, '/api/post/$postID'),
      body: jsonEncode({'body': body, 'lang': lang, 'isAdult': isAdult}));

  httpErrorHandler(response, message: "Failed to edit post");

  return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deletePost(
  http.Client client,
  String instanceHost,
  int postID,
) async {
  final response =
      await client.delete(Uri.https(instanceHost, '/api/post/$postID'));

  httpErrorHandler(response, message: "Failed to delete post");
}
