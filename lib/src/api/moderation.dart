
import 'package:interstellar/src/api/client.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/models/comment.dart';
import 'package:interstellar/src/models/post.dart';

const _postTypeMbin = {
  PostType.thread: 'entry',
  PostType.microblog: 'post',
};
const _postTypeMbinComment = {
  PostType.thread: 'comments',
  PostType.microblog: 'post-comment',
};

class APIModeration {
  final ServerClient client;

  APIModeration(this.client);

  Future<PostModel> postPin(PostType postType, int postId) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path = '/moderate/${_postTypeMbin[postType]}/$postId/pin';

        final response = await client.send(HttpMethod.put, path);

        switch (postType) {
          case PostType.thread:
            return PostModel.fromMbinEntry(response.bodyJson);
          case PostType.microblog:
            return PostModel.fromMbinPost(response.bodyJson);
        }

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<PostModel> postMarkNSFW(
      PostType postType, int postId, bool status) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path =
            '/moderate/${_postTypeMbin[postType]}/$postId/adult/$status';

        final response = await client.send(HttpMethod.put, path);

        switch (postType) {
          case PostType.thread:
            return PostModel.fromMbinEntry(response.bodyJson);
          case PostType.microblog:
            return PostModel.fromMbinPost(response.bodyJson);
        }

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<PostModel> postDelete(
      PostType postType, int postId, bool status) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path =
            '/moderate/${_postTypeMbin[postType]}/$postId/${status ? 'trash' : 'restore'}';

        final response = await client.send(HttpMethod.put, path);

        switch (postType) {
          case PostType.thread:
            return PostModel.fromMbinEntry(response.bodyJson);
          case PostType.microblog:
            return PostModel.fromMbinPost(response.bodyJson);
        }

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }

  Future<CommentModel> commentDelete(
      PostType postType, int commentId, bool status) async {
    switch (client.software) {
      case ServerSoftware.mbin:
        final path =
            '/moderate/${_postTypeMbinComment[postType]}/$commentId/${status ? 'trash' : 'restore'}';

        final response = await client.send(HttpMethod.put, path);

        return CommentModel.fromMbin(response.bodyJson);

      case ServerSoftware.lemmy:
        throw Exception('Moderation not implemented on Lemmy yet');

      case ServerSoftware.piefed:
        throw UnimplementedError();
    }
  }
}
