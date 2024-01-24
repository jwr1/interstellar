import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/models/entry.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

Future<EntryListModel> fetchEntries(
  http.Client client,
  String instanceHost,
  ContentSource source, {
  int? page,
  ContentSort? sort,
}) async {
  final response = await client.get(Uri.https(
    instanceHost,
    source.getEntriesPath(),
    removeNulls({'p': page?.toString(), 'sort': sort?.name}),
  ));

  httpErrorHandler(response, message: 'Failed to load entries');

  return EntryListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> putVote(
  http.Client client,
  String instanceHost,
  int entryId,
  int choice,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/entry/$entryId/vote/$choice',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> putFavorite(
  http.Client client,
  String instanceHost,
  int entryId,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/entry/$entryId/favourite',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> editEntry(
    http.Client client,
    String instanceHost,
    int entryID,
    String title,
    bool isOc,
    String body,
    String lang,
    bool isAdult) async {
  final response =
      await client.put(Uri.https(instanceHost, '/api/entry/$entryID'),
          body: jsonEncode({
            'title': title,
            'tags': [],
            'isOc': isOc,
            'body': body,
            'lang': lang,
            'isAdult': isAdult
          }));

  httpErrorHandler(response, message: "Failed to edit entry");

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deletePost(
  http.Client client,
  String instanceHost,
  int postID,
) async {
  final response =
      await client.delete(Uri.https(instanceHost, '/api/entry/$postID'));

  httpErrorHandler(response, message: "Failed to delete entry");
}

Future<EntryModel> createEntry(
  http.Client client,
  String instanceHost,
  int magazineID, {
  required String title,
  required bool isOc,
  required String body,
  required String lang,
  required bool isAdult,
  required List<String> tags,
}) async {
  final response = await client.post(
    Uri.https(instanceHost, '/api/magazine/$magazineID/article'),
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

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> createLink(
  http.Client client,
  String instanceHost,
  int magazineID, {
  required String title,
  required String url,
  required bool isOc,
  required String body,
  required String lang,
  required bool isAdult,
  required List<String> tags,
}) async {
  final response = await client.post(
    Uri.https(instanceHost, '/api/magazine/$magazineID/link'),
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

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> createImage(
  http.Client client,
  String instanceHost,
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
  var request = http.MultipartRequest(
      'POST', Uri.https(instanceHost, '/api/magazine/$magazineID/image'));
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
  var response = await http.Response.fromStream(await client.send(request));

  httpErrorHandler(response, message: "Failed to create entry");

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}
