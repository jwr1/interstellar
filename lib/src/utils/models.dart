import 'package:interstellar/src/models/image.dart';

DateTime? optionalDateTime(String? value) =>
    value == null ? null : DateTime.parse(value);

String? mbinCalcNextPaginationPage(Map<String, Object?> pagination) {
  return (pagination['currentPage'] as int) != (pagination['maxPage'] as int)
      ? ((pagination['currentPage'] as int) + 1).toString()
      : null;
}

ImageModel? mbinGetImage(Map<String, Object?>? json) {
  return json == null || (json['storageUrl'] ?? json['sourceUrl']) == null
      ? null
      : ImageModel.fromMbin(json);
}

ImageModel? lemmyGetImage(String? json) {
  return json == null ? null : ImageModel.fromLemmy(json);
}

String mbinNormalizeUsername(String username) {
  return username.startsWith('@') ? username.substring(1) : username;
}

String lemmyGetActorName(Map<String, Object?> json) {
  return (json['local'] as bool)
      ? (json['name'] as String)
      : '${json['name'] as String}@${Uri.parse(json['actor_id'] as String).host}';
}

String? lemmyCalcNextIntPage(
  List<dynamic> list,
  String? currentPage,
) =>
    list.isEmpty ? null : (int.parse(currentPage ?? '0') + 1).toString();
