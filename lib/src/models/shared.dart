import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared.freezed.dart';
part 'shared.g.dart';

@freezed
class ImageModel with _$ImageModel {
  const factory ImageModel({
    required String filePath,
    String? sourceUrl,
    required String storageUrl,
    String? altText,
    required int width,
    required int height,
  }) = _ImageModel;

  factory ImageModel.fromJson(Map<String, Object?> json) =>
      _$ImageModelFromJson(json);
}

@freezed
class PaginationModel with _$PaginationModel {
  const factory PaginationModel({
    required int count,
    required int currentPage,
    required int maxPage,
    required int perPage,
  }) = _PaginationModel;

  factory PaginationModel.fromJson(Map<String, Object?> json) =>
      _$PaginationModelFromJson(json);
}
