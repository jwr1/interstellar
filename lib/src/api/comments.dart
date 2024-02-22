import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';

enum CommentSort { newest, top, hot, active, oldest }

const Map<CommentSort, String> lemmyCommentSortMap = {
  CommentSort.active: 'Controversial',
  CommentSort.hot: 'Hot',
  CommentSort.newest: 'New',
  CommentSort.oldest: 'Old',
  CommentSort.top: 'Top',
};

const SelectionMenu<CommentSort> commentSortSelect = SelectionMenu(
  'Sort Comments',
  [
    SelectionMenuItem(
      value: CommentSort.hot,
      title: 'Hot',
      icon: Icons.local_fire_department,
    ),
    SelectionMenuItem(
      value: CommentSort.top,
      title: 'Top',
      icon: Icons.trending_up,
    ),
    SelectionMenuItem(
      value: CommentSort.newest,
      title: 'Newest',
      icon: Icons.auto_awesome_rounded,
    ),
    SelectionMenuItem(
      value: CommentSort.active,
      title: 'Active',
      icon: Icons.rocket_launch,
    ),
    SelectionMenuItem(
      value: CommentSort.oldest,
      title: 'Oldest',
      icon: Icons.access_time_outlined,
    ),
  ],
);

const _postTypeKbin = {
  PostType.thread: 'entry',
  PostType.microblog: 'posts',
};
const _postTypeKbinComment = {
  PostType.thread: 'comments',
  PostType.microblog: 'post-comments',
};

class APIComments {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIComments(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<CommentListModel> list(
    PostType postType,
    int postId, {
    int? page,
    CommentSort? sort,
    List<String>? langs,
    bool? usePreferredLangs,
  }) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/${_postTypeKbin[postType]}/$postId/comments';
        final query = queryParams({
          'p': page?.toString(),
          'sortBy': sort?.name,
          'lang': langs?.join(','),
          'usePreferredLangs': (usePreferredLangs ?? false).toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load comments');

        return CommentListModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/comment/list';
        final query = queryParams({
          'post_id': postId.toString(),
          'page': page?.toString(),
          'sort': lemmyCommentSortMap[sort],
          'max_depth': '8',
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load comments');

        return CommentListModel.fromLemmy(
            jsonDecode(response.body) as Map<String, Object?>);
    }
  }

  Future<CommentListModel> listFromUser(
    PostType postType,
    int userId, {
    String? page,
    CommentSort? sort,
    List<String>? langs,
    bool? usePreferredLangs,
  }) async {
    final path = '/api/users/$userId/${_postTypeKbinComment[postType]}';
    final query = queryParams({
      'p': page,
      'sortBy': sort?.name,
      'lang': langs?.join(','),
      'usePreferredLangs': (usePreferredLangs ?? false).toString(),
    });

    final response = await httpClient.get(Uri.https(server, path, query));

    httpErrorHandler(response, message: 'Failed to load comments');

    return CommentListModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<CommentModel> get(PostType postType, int commentId) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/${_postTypeKbinComment[postType]}/$commentId';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to load comment');

        return CommentModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        const path = '/api/v3/comment/list';
        final query = queryParams({
          'parent_id': commentId.toString(),
        });

        final response = await httpClient.get(Uri.https(server, path, query));

        httpErrorHandler(response, message: 'Failed to load comment');

        return CommentModel.fromLemmy(
          (jsonDecode(response.body)['comments'] as List<dynamic>).first,
          possibleChildren:
              jsonDecode(response.body)['comments'] as List<dynamic>,
        );
    }
  }

  Future<CommentModel> vote(
    PostType postType,
    int commentId,
    int choice,
    int newScore,
  ) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = choice == 1
            ? '/api/${_postTypeKbinComment[postType]}/$commentId/favourite'
            : '/api/${_postTypeKbinComment[postType]}/$commentId/vote/$choice';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send vote');

        return CommentModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);
      case ServerSoftware.lemmy:
        const path = '/api/v3/comment/like';

        final response = await httpClient.post(
          Uri.https(server, path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'comment_id': commentId,
            'score': newScore,
          }),
        );

        httpErrorHandler(response, message: 'Failed to send vote');

        return CommentModel.fromLemmy(
            jsonDecode(response.body)['comment_view'] as Map<String, Object?>);
    }
  }

  Future<CommentModel> boost(PostType postType, int commentId) async {
    switch (software) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        final path = '/api/${_postTypeKbinComment[postType]}/$commentId/vote/1';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send boost');

        return CommentModel.fromKbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Tried to boost on lemmy');
    }
  }

  Future<CommentModel> create(
    PostType postType,
    int postId,
    String body, {
    int? parentCommentId,
  }) async {
    final path =
        '/api/${_postTypeKbin[postType]}/$postId/comments${parentCommentId != null ? '/$parentCommentId/reply' : ''}';

    final response = await httpClient.post(
      Uri.https(server, path),
      body: jsonEncode({'body': body}),
    );

    httpErrorHandler(response, message: 'Failed to post comment');

    return CommentModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<CommentModel> edit(
    PostType postType,
    int commentId,
    String body,
    String lang,
    bool? isAdult,
  ) async {
    final path = '/api/${_postTypeKbinComment[postType]}/$commentId';

    final response = await httpClient.put(
      Uri.https(server, path),
      body: jsonEncode({
        'body': body,
        'lang': lang,
        'isAdult': isAdult ?? false,
      }),
    );

    httpErrorHandler(response, message: "Failed to edit comment");

    return CommentModel.fromKbin(
        jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<void> delete(PostType postType, int commentId) async {
    final path = '/api/${_postTypeKbinComment[postType]}/$commentId';

    final response = await httpClient.delete(Uri.https(server, path));

    httpErrorHandler(response, message: "Failed to delete comment");
  }
}
