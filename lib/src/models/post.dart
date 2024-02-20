import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/models.dart';

part 'post.freezed.dart';

enum PostType { thread, microblog }

@freezed
class PostListModel with _$PostListModel {
  const factory PostListModel({
    required List<PostModel> items,
    required String? nextPage,
  }) = _PostListModel;

  factory PostListModel.fromKbinEntries(Map<String, Object?> json) =>
      PostListModel(
        items: (json['items'] as List<dynamic>)
            .map(
                (post) => PostModel.fromKbinEntry(post as Map<String, Object?>))
            .toList(),
        nextPage: kbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );

  factory PostListModel.fromKbinPosts(Map<String, Object?> json) =>
      PostListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) => PostModel.fromKbinPost(post as Map<String, Object?>))
            .toList(),
        nextPage: kbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );

  factory PostListModel.fromLemmy(Map<String, Object?> json) => PostListModel(
        items: (json['posts'] as List<dynamic>)
            .map((post) => PostModel.fromLemmy(post as Map<String, Object?>))
            .toList(),
        nextPage: json['next_page'] as String?,
      );
}

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required PostType type,
    required int id,
    required UserModel user,
    required MagazineModel magazine,
    required DomainModel? domain,
    required String? title,
    required String? url,
    required String? image,
    required String? body,
    required String? lang,
    required int numComments,
    required int? upvotes,
    required int? downvotes,
    required int? boosts,
    required int? myVote,
    required bool? myBoost,
    required bool? isOc,
    required bool isAdult,
    required bool isPinned,
    required DateTime createdAt,
    required DateTime? editedAt,
    required DateTime lastActive,
    required String visibility,
  }) = _PostModel;

  factory PostModel.fromKbinEntry(Map<String, Object?> json) => PostModel(
        type: PostType.thread,
        id: json['entryId'] as int,
        user: UserModel.fromKbin(json['user'] as Map<String, Object?>),
        magazine:
            MagazineModel.fromKbin(json['magazine'] as Map<String, Object?>),
        domain: DomainModel.fromKbin(json['domain'] as Map<String, Object?>),
        title: json['title'] as String,
        url: json['url'] as String?,
        image: kbinGetImageUrl(json['image'] as Map<String, Object?>?),
        body: json['body'] as String?,
        lang: json['lang'] as String,
        numComments: json['numComments'] as int,
        upvotes: json['favourites'] as int?,
        downvotes: json['dv'] as int?,
        boosts: json['uv'] as int?,
        myVote: (json['isFavourited'] as bool?) == true
            ? 1
            : ((json['userVote'] as int?) == -1 ? -1 : 0),
        myBoost: (json['userVote'] as int?) == 1,
        isOc: json['isOc'] as bool,
        isAdult: json['isAdult'] as bool,
        isPinned: json['isPinned'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        editedAt: optionalDateTime(json['editedAt'] as String?),
        lastActive: DateTime.parse(json['lastActive'] as String),
        visibility: json['visibility'] as String,
      );

  factory PostModel.fromKbinPost(Map<String, Object?> json) => PostModel(
        type: PostType.microblog,
        id: json['postId'] as int,
        user: UserModel.fromKbin(json['user'] as Map<String, Object?>),
        magazine:
            MagazineModel.fromKbin(json['magazine'] as Map<String, Object?>),
        domain: null,
        title: null,
        url: null,
        image: kbinGetImageUrl(json['image'] as Map<String, Object?>?),
        body: json['body'] as String,
        lang: json['lang'] as String,
        numComments: json['comments'] as int,
        upvotes: json['favourites'] as int?,
        downvotes: json['dv'] as int?,
        boosts: json['uv'] as int?,
        myVote: (json['isFavourited'] as bool?) == true
            ? 1
            : ((json['userVote'] as int?) == -1 ? -1 : 0),
        myBoost: (json['userVote'] as int?) == 1,
        isOc: null,
        isAdult: json['isAdult'] as bool,
        isPinned: json['isPinned'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        editedAt: optionalDateTime(json['editedAt'] as String?),
        lastActive: DateTime.parse(json['lastActive'] as String),
        visibility: json['visibility'] as String,
      );

  factory PostModel.fromLemmy(Map<String, Object?> json) {
    final lemmyPost = json['post'] as Map<String, Object?>;
    final lemmyCounts = json['counts'] as Map<String, Object?>;

    return PostModel(
      type: PostType.thread,
      id: lemmyPost['id'] as int,
      user: UserModel.fromLemmy(json['creator'] as Map<String, Object?>),
      magazine:
          MagazineModel.fromLemmy(json['community'] as Map<String, Object?>),
      domain: null,
      title: lemmyPost['name'] as String,
      url: lemmyPost['url'] as String?,
      image: lemmyPost['thumbnail_url'] as String?,
      body: lemmyPost['body'] as String?,
      lang: null,
      numComments: lemmyCounts['comments'] as int,
      upvotes: lemmyCounts['upvotes'] as int,
      downvotes: lemmyCounts['downvotes'] as int,
      boosts: null,
      myVote: json['my_vote'] as int?,
      myBoost: null,
      isOc: null,
      isAdult: lemmyPost['nsfw'] as bool,
      isPinned: (lemmyPost['featured_community'] as bool ||
          lemmyPost['featured_local'] as bool),
      createdAt: DateTime.parse(lemmyPost['published'] as String),
      editedAt: optionalDateTime(lemmyPost['updated'] as String?),
      lastActive: DateTime.parse(lemmyCounts['newest_comment_time'] as String),
      visibility: 'visible',
    );
  }
}
