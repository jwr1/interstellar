import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/comment.dart';
import 'package:interstellar/src/models/post_comment.dart';
import 'package:interstellar/src/utils/utils.dart';

class KbinAPIPostComments {
  final http.Client httpClient;
  final String instanceHost;

  KbinAPIPostComments(
    this.httpClient,
    this.instanceHost,
  );

  Future<PostCommentListModel> list(
    int postId, {
    int? page,
    CommentSort? sort,
    List<String>? langs,
    bool? usePreferredLangs,
  }) async {
    final path = '/api/posts/$postId/comments';
    final query = queryParams({
      'p': page?.toString(),
      'sort': sort?.name,
      'lang': langs?.join(','),
      'usePreferredLangs': (usePreferredLangs ?? false).toString(),
    });

    final response = await httpClient.get(Uri.https(instanceHost, path, query));

    httpErrorHandler(response, message: 'Failed to load comments');

    return PostCommentListModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostCommentModel> get(
    int commentId,
  ) async {
    final path = '/api/post-comments/$commentId';

    final response = await httpClient.get(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to load comment');

    return PostCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostCommentModel> putVote(
    int commentId,
    int choice,
  ) async {
    final path = '/api/post-comments/$commentId/vote/$choice';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send vote');

    return PostCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostCommentModel> putFavorite(
    int commentId,
  ) async {
    final path = '/api/post-comments/$commentId/favourite';

    final response = await httpClient.put(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: 'Failed to send vote');

    return PostCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostCommentModel> create(
    String body,
    int postId, {
    int? parentCommentId,
  }) async {
    final path =
        '/api/posts/$postId/comments${parentCommentId != null ? '/$parentCommentId/reply' : ''}';

    final response = await httpClient.post(
      Uri.https(instanceHost, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to post comment');

    return PostCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostCommentModel> edit(
    int commentId,
    String body,
    String lang,
    bool? isAdult,
  ) async {
    final path = '/api/post-comments/$commentId';

    final response = await httpClient.put(
      Uri.https(instanceHost, path),
      body: jsonEncode({
        'body': body,
        'lang': lang,
        'isAdult': isAdult ?? false,
      }),
    );

    httpErrorHandler(response, message: "Failed to edit comment");

    return PostCommentModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete(
    int commentId,
  ) async {
    final path = '/api/post-comments/$commentId';

    final response = await httpClient.delete(Uri.https(instanceHost, path));

    httpErrorHandler(response, message: "Failed to delete comment");
  }
}
