import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/models.dart';
import 'package:interstellar/src/widgets/markdown/markdown_mention.dart';

part 'magazine.freezed.dart';

@freezed
class DetailedMagazineListModel with _$DetailedMagazineListModel {
  const factory DetailedMagazineListModel({
    required List<DetailedMagazineModel> items,
    required String? nextPage,
  }) = _DetailedMagazineListModel;

  factory DetailedMagazineListModel.fromMbin(Map<String, Object?> json) =>
      DetailedMagazineListModel(
        items: (json['items'] as List<dynamic>)
            .map((item) =>
                DetailedMagazineModel.fromMbin(item as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );

  factory DetailedMagazineListModel.fromLemmy(Map<String, Object?> json) =>
      DetailedMagazineListModel(
        items: (json['communities'] as List<dynamic>)
            .map((item) =>
                DetailedMagazineModel.fromLemmy(item as Map<String, Object?>))
            .toList(),
        nextPage: json['next_page'] as String?,
      );
}

@freezed
class DetailedMagazineModel with _$DetailedMagazineModel {
  const factory DetailedMagazineModel({
    required int id,
    required String name,
    required String title,
    required ImageModel? icon,
    required String? description,
    required String? rules,
    required List<UserModel> moderators,
    required int subscriptionsCount,
    required int threadCount,
    required int threadCommentCount,
    required int? microblogCount,
    required int? microblogCommentCount,
    required bool isAdult,
    required bool? isUserSubscribed,
    required bool? isBlockedByUser,
    required bool isPostingRestrictedToMods,
  }) = _DetailedMagazineModel;

  factory DetailedMagazineModel.fromMbin(Map<String, Object?> json) {
    final magazine = DetailedMagazineModel(
      id: json['magazineId'] as int,
      name: json['name'] as String,
      title: json['title'] as String,
      icon: mbinGetImage(json['icon'] as Map<String, Object?>?),
      description: json['description'] as String?,
      rules: json['rules'] as String?,
      moderators: ((json['moderators'] ?? []) as List<dynamic>)
          .map((user) => UserModel.fromMbin(user as Map<String, Object?>))
          .toList(),
      subscriptionsCount: json['subscriptionsCount'] as int,
      threadCount: json['entryCount'] as int,
      threadCommentCount: json['entryCommentCount'] as int,
      microblogCount: json['postCount'] as int,
      microblogCommentCount: json['postCommentCount'] as int,
      isAdult: json['isAdult'] as bool,
      isUserSubscribed: json['isUserSubscribed'] as bool?,
      isBlockedByUser: json['isBlockedByUser'] as bool?,
      isPostingRestrictedToMods:
          (json['isPostingRestrictedToMods'] ?? false) as bool,
    );

    magazineMentionCache[magazine.name] = magazine;

    return magazine;
  }

  factory DetailedMagazineModel.fromLemmy(Map<String, Object?> json) {
    final lemmyCommunity = json['community'] as Map<String, Object?>;
    final lemmyCounts = json['counts'] as Map<String, Object?>;

    final magazine = DetailedMagazineModel(
      id: lemmyCommunity['id'] as int,
      name: lemmyGetActorName(lemmyCommunity),
      title: lemmyCommunity['title'] as String,
      icon: lemmyGetImage(lemmyCommunity['icon'] as String?),
      description: lemmyCommunity['description'] as String?,
      rules: null,
      moderators: [],
      subscriptionsCount: lemmyCounts['subscribers'] as int,
      threadCount: lemmyCounts['posts'] as int,
      threadCommentCount: lemmyCounts['comments'] as int,
      microblogCount: null,
      microblogCommentCount: null,
      isAdult: lemmyCommunity['nsfw'] as bool,
      isUserSubscribed: (json['subscribed'] as String) != 'NotSubscribed',
      isBlockedByUser: json['blocked'] as bool?,
      isPostingRestrictedToMods:
          (lemmyCommunity['posting_restricted_to_mods']) as bool,
    );

    magazineMentionCache[magazine.name] = magazine;

    return magazine;
  }
}

@freezed
class MagazineModel with _$MagazineModel {
  const factory MagazineModel({
    required int id,
    required String name,
    required ImageModel? icon,
  }) = _MagazineModel;

  factory MagazineModel.fromMbin(Map<String, Object?> json) => MagazineModel(
        id: json['magazineId'] as int,
        name: json['name'] as String,
        icon: mbinGetImage(json['icon'] as Map<String, Object?>?),
      );

  factory MagazineModel.fromLemmy(Map<String, Object?> json) => MagazineModel(
        id: json['id'] as int,
        name: lemmyGetActorName(json),
        icon: lemmyGetImage(json['icon'] as String?),
      );
}
