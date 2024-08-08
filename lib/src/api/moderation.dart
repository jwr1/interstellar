import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';

const _postTypeMbin = {
  PostType.thread: 'entry',
  PostType.microblog: 'post',
};
const _postTypeMbinComment = {
  PostType.thread: 'comments',
  PostType.microblog: 'post-comment',
};

class APIModeration {
  final ServerSoftware software;
  final http.Client httpClient;
  final String server;

  APIModeration(
    this.software,
    this.httpClient,
    this.server,
  );

  Future<PostModel> postPin(PostType postType, int postId) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path = '/api/moderate/${_postTypeMbin[postType]}/$postId/pin';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send moderation pin');

        switch (postType) {
          case PostType.thread:
            return PostModel.fromMbinEntry(
                jsonDecode(response.body) as Map<String, Object?>);
          case PostType.microblog:
            return PostModel.fromMbinPost(
                jsonDecode(response.body) as Map<String, Object?>);
        }

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');
    }
  }

  Future<PostModel> postMarkNSFW(
      PostType postType, int postId, bool status) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path =
            '/api/moderate/${_postTypeMbin[postType]}/$postId/adult/$status';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response,
            message: 'Failed to send moderation mark NSFW');

        switch (postType) {
          case PostType.thread:
            return PostModel.fromMbinEntry(
                jsonDecode(response.body) as Map<String, Object?>);
          case PostType.microblog:
            return PostModel.fromMbinPost(
                jsonDecode(response.body) as Map<String, Object?>);
        }

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');
    }
  }

  Future<PostModel> postDelete(
      PostType postType, int postId, bool status) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path =
            '/api/moderate/${_postTypeMbin[postType]}/$postId/${status ? 'trash' : 'restore'}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send moderation delete');

        switch (postType) {
          case PostType.thread:
            return PostModel.fromMbinEntry(
                jsonDecode(response.body) as Map<String, Object?>);
          case PostType.microblog:
            return PostModel.fromMbinPost(
                jsonDecode(response.body) as Map<String, Object?>);
        }

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');
    }
  }

  Future<CommentModel> commentDelete(
      PostType postType, int commentId, bool status) async {
    switch (software) {
      case ServerSoftware.mbin:
        final path =
            '/api/moderate/${_postTypeMbinComment[postType]}/$commentId/${status ? 'trash' : 'restore'}';

        final response = await httpClient.put(Uri.https(server, path));

        httpErrorHandler(response, message: 'Failed to send moderation delete');

        return CommentModel.fromMbin(
            jsonDecode(response.body) as Map<String, Object?>);

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');
    }
  }
}
