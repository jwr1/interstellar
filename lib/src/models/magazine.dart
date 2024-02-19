import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/utils/models.dart';

part 'magazine.freezed.dart';

@freezed
class DetailedMagazineListModel with _$DetailedMagazineListModel {
  const factory DetailedMagazineListModel({
    required List<DetailedMagazineModel> items,
    required String? nextPage,
  }) = _DetailedMagazineListModel;

  factory DetailedMagazineListModel.fromKbin(Map<String, Object?> json) =>
      DetailedMagazineListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) =>
                DetailedMagazineModel.fromKbin(post as Map<String, Object?>))
            .toList(),
        nextPage: kbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );
}

@freezed
class DetailedMagazineModel with _$DetailedMagazineModel {
  const factory DetailedMagazineModel({
    required int id,
    required String name,
    required String title,
    required String? icon,
    required String? description,
    required String? rules,
    required UserModel owner,
    required List<UserModel> moderators,
    required int subscriptionsCount,
    required int entryCount,
    required int entryCommentCount,
    required int postCount,
    required int postCommentCount,
    required bool isAdult,
    required bool? isUserSubscribed,
    required bool? isBlockedByUser,
  }) = _DetailedMagazineModel;

  factory DetailedMagazineModel.fromKbin(Map<String, Object?> json) =>
      DetailedMagazineModel(
        id: json['magazineId'] as int,
        name: json['name'] as String,
        title: json['title'] as String,
        icon: kbinGetImageUrl(json['icon'] as Map<String, Object?>?),
        description: json['description'] as String?,
        rules: json['rules'] as String?,
        owner: UserModel.fromKbin(json['owner'] as Map<String, Object?>),
        moderators: ((json['moderators'] ?? []) as List<dynamic>)
            .map((user) => UserModel.fromKbin(user as Map<String, Object?>))
            .toList(),
        subscriptionsCount: json['subscriptionsCount'] as int,
        entryCount: json['entryCount'] as int,
        entryCommentCount: json['entryCommentCount'] as int,
        postCount: json['postCount'] as int,
        postCommentCount: json['postCommentCount'] as int,
        isAdult: json['isAdult'] as bool,
        isUserSubscribed: json['isUserSubscribed'] as bool?,
        isBlockedByUser: json['isBlockedByUser'] as bool?,
      );
}

@freezed
class MagazineModel with _$MagazineModel {
  const factory MagazineModel({
    required int id,
    required String name,
    required String? icon,
  }) = _MagazineModel;

  factory MagazineModel.fromKbin(Map<String, Object?> json) => MagazineModel(
        id: json['magazineId'] as int,
        name: json['name'] as String,
        icon: kbinGetImageUrl(json['icon'] as Map<String, Object?>?),
      );
}
