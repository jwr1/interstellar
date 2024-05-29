import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';

@freezed
class ImageModel with _$ImageModel {
  const factory ImageModel({
    required String src,
    required String? altText,
    required String? blurHash,
    required int? blurHashWidth,
    required int? blurHashHeight,
  }) = _ImageModel;

  factory ImageModel.fromKbin(Map<String, Object?> json) => ImageModel(
        src: (json['storageUrl'] ?? json['sourceUrl']) as String,
        altText: json['altText'] as String?,
        blurHash: json['blurHash'] as String?,
        blurHashWidth: json['width'] as int?,
        blurHashHeight: json['height'] as int?,
      );

  factory ImageModel.fromLemmy(String json) => ImageModel(
        src: json,
        altText: null,
        blurHash: null,
        blurHashWidth: null,
        blurHashHeight: null,
      );
}
