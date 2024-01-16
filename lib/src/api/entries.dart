import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/models/entry.dart';
import 'package:interstellar/src/utils/utils.dart';

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
  int magazineID,
  String title,
  bool isOc,
  String body,
  String lang,
  bool isAdult,
) async {
  final response = await client.post(Uri.https(instanceHost, '/api/magazine/$magazineID/article'),
    body: jsonEncode({
      'title': title,
      'tags': [],
      'isOc': isOc,
      'body': body,
      'lang': lang,
      'isAdult': isAdult
    })
  );

  httpErrorHandler(response, message: "Failed to create entry");

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> createLink(
  http.Client client,
  String instanceHost,
  int magazineID,
  String title,
  String url,
  bool isOc,
  String body,
  String lang,
  bool isAdult,
) async {
  final response = await client.post(Uri.https(instanceHost, '/api/magazine/$magazineID/link'),
      body: jsonEncode({
        'title': title,
        'url': url,
        'tags': [],
        'isOc': isOc,
        'body': body,
        'lang': lang,
        'isAdult': isAdult
      })
  );

  httpErrorHandler(response, message: "Failed to create entry");

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryModel> createImage(
    http.Client client,
    String instanceHost,
    int magazineID,
    String title,
    String image, //should be binary of image
    String alt,
    bool isOc,
    String body,
    String lang,
    bool isAdult,
    ) async {
  final response = await client.post(Uri.https(instanceHost, '/api/magazine/$magazineID/link'),
      body: jsonEncode({
        'title': title,
        'tags': [],
        'isOc': isOc,
        'body': body,
        'lang': lang,
        'isAdult': isAdult,
        'alt': alt,
        'uploadImage': image
      })
  );

  httpErrorHandler(response, message: "Failed to create entry");

  return EntryModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}