import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/utils/models.dart';

part 'domain.freezed.dart';

@freezed
class DomainListModel with _$DomainListModel {
  const factory DomainListModel({
    required List<DomainModel> items,
    required String? nextPage,
  }) = _DomainListModel;

  factory DomainListModel.fromMbin(Map<String, Object?> json) =>
      DomainListModel(
        items: (json['items'] as List<dynamic>)
            .map((post) => DomainModel.fromMbin(post as Map<String, Object?>))
            .toList(),
        nextPage: mbinCalcNextPaginationPage(
            json['pagination'] as Map<String, Object?>),
      );
}

@freezed
class DomainModel with _$DomainModel {
  const factory DomainModel({
    required int id,
    required String name,
    required int entryCount,
    required int subscriptionsCount,
    required bool? isUserSubscribed,
    required bool? isBlockedByUser,
  }) = _DomainModel;

  factory DomainModel.fromMbin(Map<String, Object?> json) => DomainModel(
        id: json['domainId'] as int,
        name: json['name'] as String,
        entryCount: json['entryCount'] as int,
        subscriptionsCount: json['subscriptionsCount'] as int,
        isUserSubscribed: json['isUserSubscribed'] as bool?,
        isBlockedByUser: json['isBlockedByUser'] as bool?,
      );
}
