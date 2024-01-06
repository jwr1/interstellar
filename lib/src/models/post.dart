import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/shared.dart';
import 'package:interstellar/src/models/user.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class PostListModel with _$PostListModel {
  const factory PostListModel({
    required List<PostModel> items,
    required PaginationModel pagination,
  }) = _PostListModel;

  factory PostListModel.fromJson(Map<String, Object?> json) =>
      _$PostListModelFromJson(json);
}

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required int postId,
    required MagazineModel magazine,
    required UserModel user,
    ImageModel? image,
    String? body,
    required String lang,
    required int comments,
    int? uv,
    int? dv,
    int? favourites,
    bool? isFavourited,
    int? userVote,
    required bool isAdult,
    required bool isPinned,
    required DateTime createdAt,
    DateTime? editedAt,
    required DateTime lastActive,
    required String slug,
    String? apId,
    //TODO: tags
    //TODO: mentions
    required String visibility,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, Object?> json) =>
      _$PostModelFromJson(json);
}
