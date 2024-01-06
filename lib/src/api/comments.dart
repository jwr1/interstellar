import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/utils/utils.dart';

enum CommentsSort { newest, top, hot, active, oldest }

Future<EntryCommentListModel> fetchComments(
  http.Client client,
  String instanceHost,
  int entryId, {
  int? page,
  CommentsSort? sort,
}) async {
  final response = await client.get(Uri.https(
      instanceHost,
      '/api/entry/$entryId/comments',
      removeNulls({'p': page?.toString(), 'sortBy': sort?.name})));

  httpErrorHandler(response, message: 'Failed to load comments');

  return EntryCommentListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryCommentModel> putVote(
  http.Client client,
  String instanceHost,
  int commentId,
  int choice,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/comments/$commentId/vote/$choice',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return EntryCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryCommentModel> putFavorite(
  http.Client client,
  String instanceHost,
  int commentId,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/comments/$commentId/favourite',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return EntryCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryCommentModel> postComment(
  http.Client client,
  String instanceHost,
  String body,
  int entryId, {
  int? parentCommentId,
}) async {
  final response = await client.post(
    Uri.https(
      instanceHost,
      '/api/entry/$entryId/comments${parentCommentId != null ? '/$parentCommentId/reply' : ''}',
    ),
    body: jsonEncode({'body': body}),
  );

  httpErrorHandler(response, message: 'Failed to post comment');

  return EntryCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<EntryCommentModel> editComment(http.Client client, String instanceHost,
    int commentId, String body, String lang, bool? isAdult) async {
  final response = await client.put(
      Uri.https(instanceHost, '/api/comments/$commentId'),
      body: jsonEncode(
          {'body': body, 'lang': lang, 'isAdult': isAdult ?? false}));

  httpErrorHandler(response, message: "Failed to edit comment");

  return EntryCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteComment(
  http.Client client,
  String instanceHost,
  int commentId,
) async {
  final response =
      await client.delete(Uri.https(instanceHost, '/api/comments/$commentId'));

  httpErrorHandler(response, message: "Failed to delete comment");
}
