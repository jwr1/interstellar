import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_list.freezed.dart';

@freezed
class BookmarkListListModel with _$BookmarkListListModel {
  const factory BookmarkListListModel({
    required List<BookmarkListModel> items,
  }) = _BookmarkListListModel;

  factory BookmarkListListModel.fromMbin(Map<String, Object?> json) =>
      BookmarkListListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) =>
                BookmarkListModel.fromMbin(post as Map<String, Object?>))
            .toList(),
      );
}

@freezed
class BookmarkListModel with _$BookmarkListModel {
  const factory BookmarkListModel({
    required String name,
    required bool isDefault,
    required int count,
  }) = _BookmarkListModel;

  factory BookmarkListModel.fromMbin(Map<String, Object?> json) =>
      BookmarkListModel(
        name: json['name'] as String,
        isDefault: json['isDefault'] as bool,
        count: json['count'] as int,
      );
}
