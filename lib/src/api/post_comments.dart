import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/utils/utils.dart';

enum CommentsSort { newest, top, hot, active, oldest }

Future<PostCommentListModel> fetchComments(
  http.Client client,
  String instanceHost,
  int postId, {
  int? page,
  CommentsSort? sort,
}) async {
  final response = await client.get(Uri.https(
      instanceHost,
      '/api/posts/$postId/comments',
      removeNulls({'p': page?.toString(), 'sortBy': sort?.name})));

  httpErrorHandler(response, message: 'Failed to load comments');

  return PostCommentListModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostCommentModel> putVote(
  http.Client client,
  String instanceHost,
  int commentId,
  int choice,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/post-comments/$commentId/vote/$choice',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return PostCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostCommentModel> putFavorite(
  http.Client client,
  String instanceHost,
  int commentId,
) async {
  final response = await client.put(Uri.https(
    instanceHost,
    '/api/post-comments/$commentId/favourite',
  ));

  httpErrorHandler(response, message: 'Failed to send vote');

  return PostCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostCommentModel> postComment(
  http.Client client,
  String instanceHost,
  String body,
  int postId, {
  int? parentCommentId,
}) async {
  final response = await client.post(
    Uri.https(
      instanceHost,
      '/api/posts/$postId/comments${parentCommentId != null ? '/$parentCommentId/reply' : ''}',
    ),
    body: jsonEncode({'body': body}),
  );

  httpErrorHandler(response, message: 'Failed to post comment');

  return PostCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<PostCommentModel> editComment(http.Client client, String instanceHost,
    int commentId, String body, String lang, bool? isAdult) async {
  final response = await client.put(
      Uri.https(instanceHost, '/api/post-comments/$commentId'),
      body: jsonEncode(
          {'body': body, 'lang': lang, 'isAdult': isAdult ?? false}));

  httpErrorHandler(response, message: "Failed to edit comment");

  return PostCommentModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteComment(
  http.Client client,
  String instanceHost,
  int commentId,
) async {
  final response = await client
      .delete(Uri.https(instanceHost, '/api/post-comments/$commentId'));

  httpErrorHandler(response, message: "Failed to delete comment");
}
