import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'drafts_controller.freezed.dart';

@freezed
class Draft with _$Draft {
  const Draft._();

  const factory Draft({
    required DateTime at,
    required String body,
    String? resourceId,
  }) = _Draft;

  factory Draft.fromJSONx(Map<String, Object?> json) => Draft(
        at: DateTime.parse(json['at'] as String),
        body: json['body'] as String,
        resourceId: json['resourceId'] as String?,
      );

  Map<String, dynamic> toJSONx() => {
        'at': at.toIso8601String(),
        'body': body,
        'resourceId': resourceId,
      };
}

class DraftAutoController {
  final Draft? Function() read;
  final Future<void> Function(String body) save;
  final Future<void> Function() discard;

  const DraftAutoController({
    required this.read,
    required this.save,
    required this.discard,
  });
}

class DraftsController with ChangeNotifier {
  List<Draft> _drafts = [];
  List<Draft> get drafts => _drafts;

  DraftsController() {
    _init();
  }

  Future<void> _init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _drafts = (prefs.getStringList('drafts') ?? [])
        .map((e) => Draft.fromJSONx(jsonDecode(e)))
        .toList();

    notifyListeners();
  }

  Future<void> _update() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    notifyListeners();
    await prefs.setStringList(
      'drafts',
      _drafts.map((e) => jsonEncode(e.toJSONx())).toList(),
    );
  }

  DraftAutoController auto(String resourceId) {
    return DraftAutoController(
      read: () {
        for (var draft in _drafts) {
          if (draft.resourceId == resourceId) return draft;
        }

        return null;
      },
      save: (body) async {
        _removeByResourceId(resourceId);

        drafts.add(Draft(
          at: DateTime.now(),
          body: body,
          resourceId: resourceId,
        ));

        await _update();
      },
      discard: () async {
        _removeByResourceId(resourceId);

        await _update();
      },
    );
  }

  Draft? readByDate(DateTime at) {
    for (var draft in _drafts) {
      if (draft.at == at) return draft;
    }

    return null;
  }

  Future<void> manualSave(String body) async {
    drafts.add(Draft(at: DateTime.now(), body: body));

    await _update();
  }

  void _removeByResourceId(String resourceId) {
    drafts.removeWhere((draft) => draft.resourceId == resourceId);
  }

  void _removeByDate(DateTime at) {
    drafts.removeWhere((draft) => draft.at == at);
  }

  Future<void> removeByDate(DateTime at) async {
    _removeByDate(at);

    await _update();
  }

  Future<void> removeAll() async {
    drafts.clear();

    await _update();
  }
}
