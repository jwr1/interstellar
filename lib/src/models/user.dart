import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/utils/models.dart';

part 'user.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
    required String? avatar,
    required DateTime createdAt,
    required bool isBot,
  }) = _UserModel;

  factory UserModel.fromKbin(Map<String, Object?> json) => UserModel(
        id: json['userId'] as int,
        name: json['username'] as String,
        avatar: kbinGetImageUrl(json['avatar'] as Map<String, Object?>?),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isBot: json['isBot'] as bool,
      );
}
