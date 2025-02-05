import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/bookmark_list.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/utils/models.dart';
import 'package:interstellar/src/utils/utils.dart';

enum BookmarkListSubject {
  thread,
  threadComment,
  microblog,
  microblogComment;

  factory BookmarkListSubject.fromPostType(
          {required PostType postType, required bool isComment}) =>
      isComment
          ? switch (postType) {
              PostType.thread => BookmarkListSubject.threadComment,
              PostType.microblog => BookmarkListSubject.microblogComment,
            }
          : switch (postType) {
              PostType.thread => BookmarkListSubject.thread,
              PostType.microblog => BookmarkListSubject.microblog,
            };

  String toJson() => {
        BookmarkListSubject.thread: 'entry',
        BookmarkListSubject.threadComment: 'entry_comment',
        BookmarkListSubject.microblog: 'post',
        BookmarkListSubject.microblogComment: 'post_comment',
      }[this]!;
}

class APIBookmark {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIBookmark(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<List<BookmarkListModel>> getBookmarkLists() async {
    switch (software) {
      case ServerSoftware.mbin:
        const path = '/api/bookmark-lists';

        final response = await httpClient.get(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to get bookmark lists');

        return BookmarkListListModel.fromMbin(
                jsonDecode(response.body) as Map<String, dynamic>)
            .items;

      case ServerSoftware.lemmy:
        throw Exception('Bookmarking not implemented on Lemmy');
    }
  }

  Future<List<String>?> addBookmarkToDefault({
    required BookmarkListSubject subjectType,
    required int subjectId,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/bos/$subjectId/${subjectType.toJson()}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to add bookmark');

        return optionalStringList(
            (jsonDecode(response.body) as Map<String, dynamic>)['bookmarks']);

      case ServerSoftware.lemmy:
        throw Exception('Bookmarking not implemented on Lemmy');
    }
  }

  Future<List<String>?> addBookmarkToList({
    required BookmarkListSubject subjectType,
    required int subjectId,
    required String listName,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/bol/$subjectId/${subjectType.toJson()}/$listName';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to add bookmark');

        return optionalStringList(
            (jsonDecode(response.body) as Map<String, dynamic>)['bookmarks']);

      case ServerSoftware.lemmy:
        throw Exception('Bookmarking not implemented on Lemmy');
    }
  }

  Future<List<String>?> removeBookmarkFromAll({
    required BookmarkListSubject subjectType,
    required int subjectId,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/rbo/$subjectId/${subjectType.toJson()}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to remove bookmark');

        return optionalStringList(
            (jsonDecode(response.body) as Map<String, dynamic>)['bookmarks']);

      case ServerSoftware.lemmy:
        throw Exception('Bookmarking not implemented on Lemmy');
    }
  }

  Future<List<String>?> removeBookmarkFromList({
    required BookmarkListSubject subjectType,
    required int subjectId,
    required String listName,
  }) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/rbol/$subjectId/${subjectType.toJson()}/$listName';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to remove bookmark');

        return optionalStringList(
            (jsonDecode(response.body) as Map<String, dynamic>)['bookmarks']);

      case ServerSoftware.lemmy:
        throw Exception('Bookmarking not implemented on Lemmy');
    }
  }
}
