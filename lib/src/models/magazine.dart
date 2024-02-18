import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/utils/models.dart';

part 'magazine.freezed.dart';

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
