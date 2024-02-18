import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class KbinAPIEntries {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPIEntries(
    this.httpClient,
    this.instanceHost,
  );

  Future<PostListModel> list(
    FeedSource source, {
    int? page,
    FeedSort? sort,
    List<String>? langs,
    bool? usePreferredLangs,
  }) async {
    final path = source.getEntriesPath();
    final query = queryParams({
      'p': page?.toString(),
      'sort': sort?.name,
      'lang': langs?.join(','),
      'usePreferredLangs': (usePreferredLangs ?? false).toString(),
    });

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load entries');

    return PostListModel.fromKbinEntries(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<PostModel> get(int entryId) async {
    final path = '/api/entry/$entryId';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load entries');

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<PostModel> putVote(int entryId, int choice) async {
    final path = '/api/entry/$entryId/vote/$choice';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send vote');

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<PostModel> putFavorite(int entryId) async {
    final path = '/api/entry/$entryId/favourite';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send vote');

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<PostModel> edit(
    int entryID,
    String title,
    bool isOc,
    String body,
    String lang,
    bool isAdult,
  ) async {
    final path = '/api/entry/$entryID';

    final response = await httpClient.put(
      Uri.https(instanceHost, path),
      body: jsonEncode({
        'title': title,
        'tags': [],
        'isOc': isOc,
        'body': body,
        'lang': lang,
        'isAdult': isAdult
      }),
    );

    httpErrorHandler(response, message: "Failed to edit entry");

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<void> delete(int postID) async {
    final response =
        await httpClient.delete(Uri.https(instanceHost, '/api/entry/$postID'));

    httpErrorHandler(response, message: "Failed to delete entry");
  }

  Future<PostModel> createArticle(
    int magazineID, {
    required String title,
    required bool isOc,
    required String body,
    required String lang,
    required bool isAdult,
    required List<String> tags,
  }) async {
    final path = '/api/magazine/$magazineID/article';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      body: jsonEncode({
        'title': title,
        'tags': tags,
        'isOc': isOc,
        'body': body,
        'lang': lang,
        'isAdult': isAdult
      }),
    );

    httpErrorHandler(response, message: "Failed to create entry");

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<PostModel> createLink(
    int magazineID, {
    required String title,
    required String url,
    required bool isOc,
    required String body,
    required String lang,
    required bool isAdult,
    required List<String> tags,
  }) async {
    final path = '/api/magazine/$magazineID/link';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      body: jsonEncode({
        'title': title,
        'url': url,
        'tags': tags,
        'isOc': isOc,
        'body': body,
        'lang': lang,
        'isAdult': isAdult
      }),
    );

    httpErrorHandler(response, message: "Failed to create entry");

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<PostModel> createImage(
    int magazineID, {
    required String title,
    required XFile image,
    required String alt,
    required bool isOc,
    required String body,
    required String lang,
    required bool isAdult,
    required List<String> tags,
  }) async {
    final path = '/api/magazine/$magazineID/image';

    var request = http.MultipartRequest('POST', Uri.https(instanceHost, path));
    var multipartFile = http.MultipartFile.fromBytes(
      'uploadImage',
      await image.readAsBytes(),
      filename: basename(image.path),
      contentType: MediaType.parse(lookupMimeType(image.path)!),
    );
    request.files.add(multipartFile);
    request.fields['title'] = title;
    for (int i = 0; i < tags.length; i++) {
      request.fields['tags[$i]'] = tags[i];
    }
    request.fields['isOc'] = isOc.toString();
    request.fields['body'] = body;
    request.fields['lang'] = lang;
    request.fields['isAdult'] = isAdult.toString();
    request.fields['alt'] = alt;
    var response =
        await http.Response.fromStream(await httpClient.send(request));

    httpErrorHandler(response, message: "Failed to create entry");

    return PostModel.fromKbinEntry(
        jsonDecode(response.body) as Map<String, Object?>);
  }
}
