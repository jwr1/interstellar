import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/comment.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/api/oauth.dart';
import 'package:interstellar/src/screens/feed_screen.dart';
import 'package:interstellar/src/utils/themes.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  late String _themeAccent;
  String get themeAccent => _themeAccent;
  ThemeInfo get theme => themes[_themeAccent]!;
  late FeedMode _defaultFeedMode;
  FeedMode get defaultFeedMode => _defaultFeedMode;
  late FeedSort _defaultEntriesFeedSort;
  FeedSort get defaultEntriesFeedSort => _defaultEntriesFeedSort;
  late FeedSort _defaultPostsFeedSort;
  FeedSort get defaultPostsFeedSort => _defaultPostsFeedSort;
  late FeedSort _defaultExploreFeedSort;
  FeedSort get defaultExploreFeedSort => _defaultExploreFeedSort;
  late CommentSort _defaultCommentSort;
  CommentSort get defaultCommentSort => _defaultCommentSort;

  late Map<String, String> _oauthIdentifiers;
  late Map<String, oauth2.Credentials?> _oauthCredentials;
  late String _selectedAccount;
  late http.Client _httpClient;

  Map<String, String> get oauthIdentifiers => _oauthIdentifiers;
  Map<String, oauth2.Credentials?> get oauthCredentials => _oauthCredentials;
  String get selectedAccount => _selectedAccount;
  String get instanceHost => _selectedAccount.split('@').last;
  bool get isLoggedIn => _selectedAccount.split('@').first.isNotEmpty;
  http.Client get httpClient => _httpClient;

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _themeMode = prefs.getString('themeMode') != null
        ? ThemeMode.values.byName(prefs.getString("themeMode")!)
        : ThemeMode.system;
    _themeAccent = prefs.getString("themeAccent") != null
        ? prefs.getString("themeAccent")!
        : "Default";
    _defaultFeedMode = prefs.getString('defaultFeedMode') != null
        ? FeedMode.values.byName(prefs.getString("defaultFeedMode")!)
        : FeedMode.entries;
    _defaultEntriesFeedSort = prefs.getString('defaultEntriesFeedSort') != null
        ? FeedSort.values.byName(prefs.getString("defaultEntriesFeedSort")!)
        : FeedSort.hot;
    _defaultPostsFeedSort = prefs.getString('defaultPostsFeedSort') != null
        ? FeedSort.values.byName(prefs.getString("defaultPostsFeedSort")!)
        : FeedSort.hot;
    _defaultExploreFeedSort = prefs.getString('defaultExploreFeedSort') != null
        ? FeedSort.values.byName(prefs.getString("defaultExploreFeedSort")!)
        : FeedSort.newest;
    _defaultCommentSort = prefs.getString('defaultCommentSort') != null
        ? CommentSort.values.byName(prefs.getString("defaultCommentSort")!)
        : CommentSort.hot;

    _oauthIdentifiers = (jsonDecode(prefs.getString('oauthIdentifiers') ?? '{}')
            as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value));
    _oauthCredentials = (jsonDecode(
                prefs.getString('oauthCredentials') ?? '{"@kbin.earth":null}')
            as Map<String, dynamic>)
        .map((key, value) => MapEntry(
            key, value != null ? oauth2.Credentials.fromJson(value) : null));
    _selectedAccount = prefs.getString('selectedAccount') ?? '@kbin.earth';
    updateHttpClient();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newThemeMode.name);
  }

  Future<void> updateThemeAccent(String? newThemeAccent) async {
    if (newThemeAccent == null) return;

    if (newThemeAccent == _themeAccent) return;

    _themeAccent = newThemeAccent;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeAccent', newThemeAccent);
  }

  Future<void> updateDefaultFeedMode(FeedMode? newDefaultFeedMode) async {
    if (newDefaultFeedMode == null) return;

    if (newDefaultFeedMode == _defaultFeedMode) return;

    _defaultFeedMode = newDefaultFeedMode;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultFeedMode', newDefaultFeedMode.name);
  }

  Future<void> updateDefaultEntriesFeedSort(
      FeedSort? newDefaultFeedSort) async {
    if (newDefaultFeedSort == null) return;

    if (newDefaultFeedSort == _defaultEntriesFeedSort) return;

    _defaultEntriesFeedSort = newDefaultFeedSort;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultFeedSortEntries', newDefaultFeedSort.name);
  }

  Future<void> updateDefaultPostsFeedSort(FeedSort? newDefaultFeedSort) async {
    if (newDefaultFeedSort == null) return;

    if (newDefaultFeedSort == _defaultPostsFeedSort) return;

    _defaultPostsFeedSort = newDefaultFeedSort;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultPostsFeedSort', newDefaultFeedSort.name);
  }

  Future<void> updateDefaultExploreFeedSort(
    FeedSort? newDefaultExploreFeedSort,
  ) async {
    if (newDefaultExploreFeedSort == null) return;

    if (newDefaultExploreFeedSort == _defaultExploreFeedSort) return;

    _defaultExploreFeedSort = newDefaultExploreFeedSort;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'defaultExploreFeedSort', newDefaultExploreFeedSort.name);
  }

  Future<void> updateDefaultCommentSort(
    CommentSort? newDefaultCommentSort,
  ) async {
    if (newDefaultCommentSort == null) return;

    if (newDefaultCommentSort == _defaultCommentSort) return;

    _defaultCommentSort = newDefaultCommentSort;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultCommentSort', newDefaultCommentSort.name);
  }

  Future<String> getOAuthIdentifier(String instanceHost) async {
    if (_oauthIdentifiers.containsKey(instanceHost)) {
      return _oauthIdentifiers[instanceHost]!;
    }

    String oauthIdentifier = await registerOAuthApp(instanceHost);
    _oauthIdentifiers[instanceHost] = oauthIdentifier;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthIdentifiers', jsonEncode(_oauthIdentifiers));

    return oauthIdentifier;
  }

  Future<void> setOAuthCredentials(String key, oauth2.Credentials? value,
      {bool? switchNow}) async {
    _oauthCredentials[key] = value;

    if (switchNow ?? false) {
      _selectedAccount = key;
    }

    updateHttpClient();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthCredentials', jsonEncode(_oauthCredentials));
    if (switchNow ?? false) {
      await prefs.setString('selectedAccount', key);
    }
  }

  Future<void> removeOAuthCredentials(String key) async {
    if (!_oauthCredentials.containsKey(key)) return;

    _oauthCredentials.remove(key);
    _selectedAccount = _oauthCredentials.keys.firstOrNull ?? '@kbin.earth';

    updateHttpClient();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthCredentials', jsonEncode(_oauthCredentials));
    await prefs.setString('selectedAccount', _selectedAccount);
  }

  Future<void> setSelectedAccount(String? newSelectedAccount) async {
    if (newSelectedAccount == null) return;

    if (newSelectedAccount == _selectedAccount) return;

    _selectedAccount = newSelectedAccount;
    updateHttpClient();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', newSelectedAccount);
  }

  Future<void> updateHttpClient() async {
    oauth2.Credentials? credentials = _oauthCredentials[_selectedAccount];

    if (credentials == null) {
      _httpClient = http.Client();
    } else {
      String identifier = _oauthIdentifiers[instanceHost]!;

      _httpClient = oauth2.Client(
        credentials,
        identifier: identifier,
        onCredentialsRefreshed: (newCredentials) async {
          _oauthCredentials[_selectedAccount] = newCredentials;

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'oauthCredentials', jsonEncode(_oauthCredentials));
        },
      );
    }
  }
}
