import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/models/shared.dart';

part 'domain.freezed.dart';
part 'domain.g.dart';

@freezed
class DomainListModel with _$DomainListModel {
  const factory DomainListModel({
    required List<DomainModel> items,
    required PaginationModel pagination,
  }) = _DomainListModel;

  factory DomainListModel.fromJson(Map<String, Object?> json) =>
      _$DomainListModelFromJson(json);
}

@freezed
class DomainModel with _$DomainModel {
  const factory DomainModel({
    required String name,
    required int entryCount,
    required int subscriptionsCount,
    bool? isUserSubscribed,
    bool? isBlockedByUser,
    required int domainId,
  }) = _DomainModel;

  factory DomainModel.fromJson(Map<String, Object?> json) =>
      _$DomainModelFromJson(json);
}
