DateTime? optionalDateTime(String? value) =>
    value == null ? null : DateTime.parse(value);

String? kbinCalcNextPaginationPage(Map<String, Object?> pagination) {
  return (pagination['currentPage'] as int) != (pagination['maxPage'] as int)
      ? ((pagination['currentPage'] as int) + 1).toString()
      : null;
}

String? kbinGetImageUrl(Map<String, Object?>? image) {
  return image == null ? null : image['storageUrl'] as String;
}

String kbinNormalizeUsername(String username) {
  return username.startsWith('@') ? username.substring(1) : username;
}

String lemmyGetActorName(Map<String, Object?> json) {
  return (json['local'] as bool)
      ? (json['name'] as String)
      : '${json['name'] as String}@${Uri.parse(json['actor_id'] as String).host}';
}
