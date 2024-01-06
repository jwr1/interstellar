import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/models/user.dart';

part 'entry_comment.freezed.dart';
part 'entry_comment.g.dart';

@freezed
class EntryCommentListModel with _$EntryCommentListModel {
  const factory EntryCommentListModel({
    required List<EntryCommentModel> items,
    required PaginationModel pagination,
  }) = _EntryCommentListModel;

  factory EntryCommentListModel.fromJson(Map<String, Object?> json) =>
      _$EntryCommentListModelFromJson(json);
}

@freezed
class EntryCommentModel with _$EntryCommentModel {
  const factory EntryCommentModel({
    required int commentId,
    required UserModel user,
    required MagazineModel magazine,
    required int entryId,
    int? parentId,
    int? rootId,
    ImageModel? image,
    String? body,
    required String lang,
    List<String>? mentions,
    int? uv,
    int? dv,
    int? favourites,
    bool? isFavourited,
    int? userVote,
    bool? isAdult,
    required DateTime createdAt,
    DateTime? editedAt,
    required DateTime lastActive,
    String? apId,
    List<EntryCommentModel>? children,
    required int childCount,
    required String visibility,
  }) = _EntryCommentModel;

  factory EntryCommentModel.fromJson(Map<String, Object?> json) =>
      _$EntryCommentModelFromJson(json);
}
