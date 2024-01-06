import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/models/user.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class EntryListModel with _$EntryListModel {
  const factory EntryListModel({
    required List<EntryModel> items,
    required PaginationModel pagination,
  }) = _EntryListModel;

  factory EntryListModel.fromJson(Map<String, Object?> json) =>
      _$EntryListModelFromJson(json);
}

@freezed
class EntryModel with _$EntryModel {
  const factory EntryModel({
    required int entryId,
    required MagazineModel magazine,
    required UserModel user,
    required DomainModel domain,
    required String title,
    String? url,
    ImageModel? image,
    String? body,
    required String lang,
    required int numComments,
    int? uv,
    int? dv,
    int? favourites,
    bool? isFavourited,
    int? userVote,
    required bool isOc,
    required bool isAdult,
    required bool isPinned,
    required DateTime createdAt,
    DateTime? editedAt,
    required DateTime lastActive,
    required String type,
    required String slug,
    String? apId,
    required String visibility,
  }) = _EntryModel;

  factory EntryModel.fromJson(Map<String, Object?> json) =>
      _$EntryModelFromJson(json);
}
