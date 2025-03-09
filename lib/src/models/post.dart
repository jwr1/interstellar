import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/notification.dart';
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

  factory PostListModel.fromMbinEntries(Map<String, Object?> json) =>
      PostListModel(
        items: (json['items'] as List<dynamic>)
            .map(
                (post) => PostModel.fromMbinEntry(post as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );

  factory PostListModel.fromMbinPosts(Map<String, Object?> json) =>
      PostListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) => PostModel.fromMbinPost(post as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );

  factory PostListModel.fromLemmy(Map<String, Object?> json) => PostListModel(
        items: (json['posts'] as List<dynamic>)
            .map((post) => PostModel.fromLemmy(post as Map<String, Object?>))
            .toList(),
        nextPage: json['next_page'] as String?,
      );

  factory PostListModel.fromPiefed(Map<String, Object?> json) => PostListModel(
        items: (json['posts'] as List<dynamic>)
            .map((post) => PostModel.fromPiefed(post as Map<String, Object?>))
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
    required ImageModel? image,
    required String? body,
    required String? lang,
    required int numComments,
    required int? upvotes,
    required int? downvotes,
    required int? boosts,
    required int? myVote,
    required bool? myBoost,
    required bool? isOC,
    required bool isNSFW,
    required bool isPinned,
    required DateTime createdAt,
    required DateTime? editedAt,
    required DateTime lastActive,
    required String visibility,
    required bool? canAuthUserModerate,
    required NotificationControlStatus? notificationControlStatus,
    required List<String>? bookmarks,
  }) = _PostModel;

  factory PostModel.fromMbinEntry(Map<String, Object?> json) => PostModel(
        type: PostType.thread,
        id: json['entryId'] as int,
        user: UserModel.fromMbin(json['user'] as Map<String, Object?>),
        magazine:
            MagazineModel.fromMbin(json['magazine'] as Map<String, Object?>),
        domain: json['domain'] == null
            ? null
            : DomainModel.fromMbin(json['domain'] as Map<String, Object?>),
        title: json['title'] as String?,
        // Only include link if it's not an Image post
        url: (json['type'] == 'image' && json['image'] != null)
            ? null
            : json['url'] as String?,
        image: mbinGetImage(json['image'] as Map<String, Object?>?),
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
        isOC: json['isOc'] as bool,
        isNSFW: json['isAdult'] as bool,
        isPinned: json['isPinned'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        editedAt: optionalDateTime(json['editedAt'] as String?),
        lastActive: DateTime.parse(json['lastActive'] as String),
        visibility: json['visibility'] as String,
        canAuthUserModerate: json['canAuthUserModerate'] as bool?,
        notificationControlStatus: json['notificationStatus'] == null
            ? null
            : NotificationControlStatus.fromJson(
                json['notificationStatus'] as String),
        bookmarks: optionalStringList(json['bookmarks']),
      );

  factory PostModel.fromMbinPost(Map<String, Object?> json) => PostModel(
        type: PostType.microblog,
        id: json['postId'] as int,
        user: UserModel.fromMbin(json['user'] as Map<String, Object?>),
        magazine:
            MagazineModel.fromMbin(json['magazine'] as Map<String, Object?>),
        domain: null,
        title: null,
        url: null,
        image: mbinGetImage(json['image'] as Map<String, Object?>?),
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
        isOC: null,
        isNSFW: json['isAdult'] as bool,
        isPinned: json['isPinned'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        editedAt: optionalDateTime(json['editedAt'] as String?),
        lastActive: DateTime.parse(json['lastActive'] as String),
        visibility: json['visibility'] as String,
        canAuthUserModerate: json['canAuthUserModerate'] as bool?,
        notificationControlStatus: json['notificationStatus'] == null
            ? null
            : NotificationControlStatus.fromJson(
                json['notificationStatus'] as String),
        bookmarks: optionalStringList(json['bookmarks']),
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
      // Only include link if it's not an Image post
      url: (lemmyPost['url_content_type'] != null &&
              (lemmyPost['url_content_type'] as String).startsWith('image/'))
          ? null
          : lemmyPost['url'] as String?,
      image: lemmyGetImage(lemmyPost['thumbnail_url'] as String?),
      body: lemmyPost['body'] as String?,
      lang: null,
      numComments: lemmyCounts['comments'] as int,
      upvotes: lemmyCounts['upvotes'] as int,
      downvotes: lemmyCounts['downvotes'] as int,
      boosts: null,
      myVote: json['my_vote'] as int?,
      myBoost: null,
      isOC: null,
      isNSFW: lemmyPost['nsfw'] as bool,
      isPinned: lemmyPost['featured_community'] as bool ||
          lemmyPost['featured_local'] as bool,
      createdAt: DateTime.parse(lemmyPost['published'] as String),
      editedAt: optionalDateTime(lemmyPost['updated'] as String?),
      lastActive: DateTime.parse(lemmyCounts['newest_comment_time'] as String),
      visibility: 'visible',
      canAuthUserModerate: null,
      notificationControlStatus: null,
      bookmarks: [
        // Empty string indicates post is saved. No string indicates post is not saved.
        if (json['saved'] as bool) '',
      ],
    );
  }

  factory PostModel.fromPiefed(Map<String, Object?> json) {
    final piefedPost = json['post'] as Map<String, Object?>;
    final piefedCounts = json['counts'] as Map<String, Object?>;

    return PostModel(
      type: PostType.thread,
      id: piefedPost['id'] as int,
      user: UserModel.fromPiefed(json['creator'] as Map<String, Object?>),
      magazine:
          MagazineModel.fromPiefed(json['community'] as Map<String, Object?>),
      domain: null,
      title: piefedPost['title'] as String,
      // Only include link if it's not an Image post
      url: (piefedPost['url_content_type'] != null &&
              (piefedPost['url_content_type'] as String).startsWith('image/'))
          ? null
          : piefedPost['url'] as String?,
      image: lemmyGetImage(piefedPost['thumbnail_url'] as String?),
      body: piefedPost['body'] as String?,
      lang: null,
      numComments: piefedCounts['comments'] as int,
      upvotes: piefedCounts['upvotes'] as int,
      downvotes: piefedCounts['downvotes'] as int,
      boosts: null,
      myVote: json['my_vote'] as int?,
      myBoost: null,
      isOC: null,
      isNSFW: piefedPost['nsfw'] as bool,
      isPinned: false,
      createdAt: DateTime.parse(piefedPost['published'] as String),
      editedAt: optionalDateTime(piefedPost['updated'] as String?),
      lastActive: DateTime.parse(piefedCounts['newest_comment_time'] as String),
      visibility: 'visible',
      canAuthUserModerate: null,
      notificationControlStatus: json['activity_alert'] == null
          ? null
          : json['activity_alert'] as bool
              ? NotificationControlStatus.loud
              : NotificationControlStatus.default_,
      bookmarks: [
        // Empty string indicates post is saved. No string indicates post is not saved.
        if (json['saved'] as bool) '',
      ],
    );
  }
}
