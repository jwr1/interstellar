import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oauth2/oauth2.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory Account({
    Credentials? oauth,
    String? jwt,
    bool? isPushRegistered,
  }) = _Account;

  factory Account.fromJson(Map<String, Object?> json) =>
      _$AccountFromJson(json);
}
