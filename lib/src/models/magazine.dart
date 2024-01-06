import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/shared.dart';

part 'magazine.freezed.dart';
part 'magazine.g.dart';

@freezed
class MagazineListModel with _$MagazineListModel {
  const factory MagazineListModel({
    required List<DetailedMagazineModel> items,
    required PaginationModel pagination,
  }) = _MagazineListModel;

  factory MagazineListModel.fromJson(Map<String, Object?> json) =>
      _$MagazineListModelFromJson(json);
}

@freezed
class DetailedMagazineModel with _$DetailedMagazineModel {
  const factory DetailedMagazineModel({
    required ModeratorModel owner,
    ImageModel? icon,
    required String name,
    required String title,
    String? description,
    String? rules,
    required int subscriptionsCount,
    required int entryCount,
    required int entryCommentCount,
    required int postCount,
    required int postCommentCount,
    required bool isAdult,
    bool? isUserSubscribed,
    bool? isBlockedByUser,
    List<String>? tags,
    List<ModeratorModel>? moderators,
    String? apId,
    String? apProfileId,
    required int magazineId,
  }) = _DetailedMagazineModel;

  factory DetailedMagazineModel.fromJson(Map<String, Object?> json) =>
      _$DetailedMagazineModelFromJson(json);
}

@freezed
class ModeratorModel with _$ModeratorModel {
  const factory ModeratorModel({
    required int magazineId,
    required int userId,
    ImageModel? avatar,
    required String username,
    String? apId,
  }) = _ModeratorModel;

  factory ModeratorModel.fromJson(Map<String, Object?> json) =>
      _$ModeratorModelFromJson(json);
}

@freezed
class MagazineModel with _$MagazineModel {
  const factory MagazineModel({
    required String name,
    required int magazineId,
    ImageModel? icon,
    bool? isUserSubscribed,
    bool? isBlockedByUser,
    String? apId,
    required String apProfileId,
  }) = _MagazineModel;

  factory MagazineModel.fromJson(Map<String, Object?> json) =>
      _$MagazineModelFromJson(json);
}
