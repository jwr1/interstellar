String? kbinCalcNextPaginationPage(Map<String, Object?> pagination) {
  return (pagination['currentPage'] as int) != (pagination['maxPage'] as int)
      ? ((pagination['currentPage'] as int) + 1).toString()
      : null;
}

String? kbinGetImageUrl(Map<String, Object?>? image) {
  return image == null ? null : image['storageUrl'] as String;
}

DateTime? optionalDateTime(String? value) =>
    value == null ? null : DateTime.parse(value);
