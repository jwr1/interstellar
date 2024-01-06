import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/models/user.dart';

part 'post_comment.freezed.dart';
part 'post_comment.g.dart';

@freezed
class PostCommentListModel with _$PostCommentListModel {
  const factory PostCommentListModel({
    required List<PostCommentModel> items,
    required PaginationModel pagination,
  }) = _PostCommentListModel;

  factory PostCommentListModel.fromJson(Map<String, Object?> json) =>
      _$PostCommentListModelFromJson(json);
}

@freezed
class PostCommentModel with _$PostCommentModel {
  const factory PostCommentModel({
    required int commentId,
    required UserModel user,
    required MagazineModel magazine,
    required int postId,
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
    List<PostCommentModel>? children,
    required int childCount,
    required String visibility,
  }) = _PostCommentModel;

  factory PostCommentModel.fromJson(Map<String, Object?> json) =>
      _$PostCommentModelFromJson(json);
}
