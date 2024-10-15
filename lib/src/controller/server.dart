import 'package:freezed_annotation/freezed_annotation.dart';

part 'server.freezed.dart';
part 'server.g.dart';

enum ServerSoftware { mbin, lemmy }

@freezed
class Server with _$Server {
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory Server({
    required ServerSoftware software,
    String? oauthIdentifier,
  }) = _Server;

  factory Server.fromJson(Map<String, Object?> json) => _$ServerFromJson(json);
}
