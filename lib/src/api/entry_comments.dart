import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/comment.dart';
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/utils/utils.dart';

class KbinAPIEntryComments {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPIEntryComments(
    this.httpClient,
    this.instanceHost,
  );

  Future<EntryCommentListModel> list(
    int entryId, {
    int? page,
    CommentSort? sort,
    List<String>? langs,
    bool? usePreferredLangs,
  }) async {
    final path = '/api/entry/$entryId/comments';
    final query = queryParams({
      'p': page?.toString(),
      'sortBy': sort?.name,
      'lang': langs?.join(','),
      'usePreferredLangs': (usePreferredLangs ?? false).toString(),
    });

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load comments');

    return EntryCommentListModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<EntryCommentModel> get(int commentId) async {
    final path = '/api/comments/$commentId';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load comment');

    return EntryCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<EntryCommentModel> putVote(int commentId, int choice) async {
    final path = '/api/comments/$commentId/vote/$choice';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send vote');

    return EntryCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<EntryCommentModel> putFavorite(int commentId) async {
    final path = '/api/comments/$commentId/favourite';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send vote');

    return EntryCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<EntryCommentModel> create(
    String body,
    int entryId, {
    int? parentCommentId,
  }) async {
    final path =
        '/api/entry/$entryId/comments${parentCommentId != null ? '/$parentCommentId/reply' : ''}';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to post comment');

    return EntryCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<EntryCommentModel> edit(
    int commentId,
    String body,
    String lang,
    bool? isAdult,
  ) async {
    final path = '/api/comments/$commentId';

    final response = await httpClient.put(
      Uri.https(instanceHost, path),
      body: jsonEncode({
        'body': body,
        'lang': lang,
        'isAdult': isAdult ?? false,
      }),
    );

    httpErrorHandler(response, message: "Failed to edit comment");

    return EntryCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete(
    int commentId,
  ) async {
    final path = '/api/comments/$commentId';

    final response = await httpClient.delete(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: "Failed to delete comment");
  }
}
