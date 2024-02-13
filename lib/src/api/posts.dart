import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

Future<PostListModel> fetchPosts(
  http.Client client,
  String instanceHost,
  FeedSource source, {
  int? page,
  FeedSort? sort,
  List<String>? langs,
  bool? usePreferredLangs,
}) async {
  if (source.getPostsPath() == null) {
    throw Exception('Failed to load posts');
  }

  final response = await client.get(Uri.https(
      instanceHost,
      source.getPostsPath()!,
      queryParams({
        'p': page?.toString(),
        'sort': sort?.name,
        'lang': langs?.join(','),
        'usePreferredLangs': (usePreferredLangs ?? false).toString(),
      })));

  httpErrorHandler(response, message: 'Failed to load posts');

  return PostListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostModel> fetchPost(
    http.Client client, String instanceHost, int postId) async {
  final response =
      await client.get(Uri.https(instanceHost, '/api/post/$postId'));

  httpErrorHandler(response, message: 'Failed to load posts');

  return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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

Future<PostModel> createPost(
  http.Client client,
  String instanceHost,
  int magazineID, {
  required String body,
  required String lang,
  required bool isAdult,
}) async {
  final response = await client.post(
      Uri.https(instanceHost, '/api/magazine/$magazineID/posts'),
      body: jsonEncode({'body': body, 'lang': lang, 'isAdult': isAdult}));

  httpErrorHandler(response, message: "Failed to create post");

  return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostModel> createImage(
  http.Client client,
  String instanceHost,
  int magazineID, {
  required XFile image,
  required String alt,
  required String body,
  required String lang,
  required bool isAdult,
}) async {
  var request = http.MultipartRequest(
      'POST', Uri.https(instanceHost, '/api/magazine/$magazineID/posts/image'));
  var multipartFile = http.MultipartFile.fromBytes(
    'uploadImage',
    await image.readAsBytes(),
    filename: basename(image.path),
    contentType: MediaType.parse(lookupMimeType(image.path)!),
  );
  request.files.add(multipartFile);
  request.fields['body'] = body;
  request.fields['lang'] = lang;
  request.fields['isAdult'] = isAdult.toString();
  request.fields['alt'] = alt;
  var response = await http.Response.fromStream(await client.send(request));

  httpErrorHandler(response, message: "Failed to create post");

  return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}
