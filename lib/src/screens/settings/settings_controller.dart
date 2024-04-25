import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/api.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/api/oauth.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/utils/jwt_http_client.dart';
import 'package:interstellar/src/utils/themes.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/actions.dart';
import 'package:interstellar/src/widgets/markdown_mention.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

enum ServerSoftware { kbin, mbin, lemmy }

enum PostLayout { auto, narrow, wide }

class Server {
  final ServerSoftware software;
  final String? oauthIdentifier;

  Server(this.software, {this.oauthIdentifier});

  factory Server.fromJson(Map<String, Object?> json) => Server(
        ServerSoftware.values.byName(json['software'] as String),
        oauthIdentifier: json['oauthIdentifier'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'software': software.name,
        'oauthIdentifier': oauthIdentifier,
      };
}

class Account {
  final oauth2.Credentials? oauth;
  final String? jwt;

  Account({this.oauth, this.jwt});

  factory Account.fromJson(Map<String, Object?> json) => Account(
        oauth: json['oauth'] == null
            ? null
            : oauth2.Credentials.fromJson(json['oauth'] as String),
        jwt: json['jwt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'oauth': oauth?.toJson(),
        'jwt': jwt,
      };
}

class SettingsController with ChangeNotifier {
  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  late bool _useDynamicColor;
  bool get useDynamicColor => _useDynamicColor;
  late String _accentColor;
  String get accentColor => _accentColor;
  ThemeInfo get theme =>
      themes.firstWhere((theme) => theme.name == _accentColor);

  late bool _alwaysShowInstance;
  bool get alwaysShowInstance => _alwaysShowInstance;
  late PostLayout _postLayout;
  PostLayout get postLayout => _postLayout;

  late ActionLocation _feedActionBackToTop;
  ActionLocation get feedActionBackToTop => _feedActionBackToTop;
  late ActionLocation _feedActionCreatePost;
  ActionLocation get feedActionCreatePost => _feedActionCreatePost;
  late ActionLocation _feedActionExpandFab;
  ActionLocation get feedActionExpandFab => _feedActionExpandFab;
  late ActionLocation _feedActionRefresh;
  ActionLocation get feedActionRefresh => _feedActionRefresh;
  late ActionLocationWithTabs _feedActionSetFilter;
  ActionLocationWithTabs get feedActionSetFilter => _feedActionSetFilter;
  late ActionLocation _feedActionSetSort;
  ActionLocation get feedActionSetSort => _feedActionSetSort;
  late ActionLocationWithTabs _feedActionSetType;
  ActionLocationWithTabs get feedActionSetType => _feedActionSetType;

  late PostType _defaultFeedType;
  PostType get defaultFeedType => _defaultFeedType;
  late FeedSort _defaultEntriesFeedSort;
  FeedSort get defaultEntriesFeedSort => _defaultEntriesFeedSort;
  late FeedSort _defaultPostsFeedSort;
  FeedSort get defaultPostsFeedSort => _defaultPostsFeedSort;
  late FeedSort _defaultExploreFeedSort;
  FeedSort get defaultExploreFeedSort => _defaultExploreFeedSort;
  late CommentSort _defaultCommentSort;
  CommentSort get defaultCommentSort => _defaultCommentSort;

  late bool _useAccountLangFilter;
  bool get useAccountLangFilter => _useAccountLangFilter;
  late Set<String> _langFilter;
  Set<String> get langFilter => _langFilter;
  late String _defaultCreateLang;
  String get defaultCreateLang => _defaultCreateLang;

  late Map<String, Server> _servers;
  late Map<String, Account> _accounts;
  late String _selectedAccount;
  late API _api;

  Map<String, Server> get servers => _servers;
  Map<String, Account> get accounts => _accounts;
  String get selectedAccount => _selectedAccount;
  String get instanceHost => _selectedAccount.split('@').last;
  bool get isLoggedIn => _selectedAccount.split('@').first.isNotEmpty;
  ServerSoftware get serverSoftware => _servers[instanceHost]!.software;
  API get api => _api;

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _themeMode = parseEnum(
      ThemeMode.values,
      ThemeMode.system,
      prefs.getString("themeMode"),
    );
    _useDynamicColor = prefs.getBool("useDynamicColor") != null
        ? prefs.getBool("useDynamicColor")!
        : true;
    _accentColor = prefs.getString("accentColor") != null
        ? prefs.getString("accentColor")!
        : "Default";

    _alwaysShowInstance = prefs.getBool("alwaysShowInstance") != null
        ? prefs.getBool("alwaysShowInstance")!
        : false;
    _postLayout = parseEnum(
      PostLayout.values,
      PostLayout.auto,
      prefs.getString("postLayout"),
    );

    _feedActionBackToTop = parseEnum(
      ActionLocation.values,
      ActionLocation.fabMenu,
      prefs.getString("feedActionBackToTop"),
    );
    _feedActionCreatePost = parseEnum(
      ActionLocation.values,
      ActionLocation.fabMenu,
      prefs.getString("feedActionCreatePost"),
    );
    _feedActionExpandFab = parseEnum(
      ActionLocation.values,
      ActionLocation.fabTap,
      prefs.getString("feedActionExpandFab"),
    );
    _feedActionRefresh = parseEnum(
      ActionLocation.values,
      ActionLocation.fabMenu,
      prefs.getString("feedActionRefresh"),
    );
    _feedActionSetFilter = parseEnum(
      ActionLocationWithTabs.values,
      ActionLocationWithTabs.tabs,
      prefs.getString("feedActionSetFilter"),
    );
    _feedActionSetSort = parseEnum(
      ActionLocation.values,
      ActionLocation.appBar,
      prefs.getString("feedActionSetSort"),
    );
    _feedActionSetType = parseEnum(
      ActionLocationWithTabs.values,
      ActionLocationWithTabs.appBar,
      prefs.getString("feedActionSetType"),
    );

    _defaultFeedType = parseEnum(
      PostType.values,
      PostType.thread,
      prefs.getString("defaultFeedType"),
    );
    _defaultEntriesFeedSort = parseEnum(
      FeedSort.values,
      FeedSort.hot,
      prefs.getString('defaultEntriesFeedSort'),
    );
    _defaultPostsFeedSort = parseEnum(
      FeedSort.values,
      FeedSort.hot,
      prefs.getString('defaultPostsFeedSort'),
    );
    _defaultExploreFeedSort = parseEnum(
      FeedSort.values,
      FeedSort.hot,
      prefs.getString('defaultExploreFeedSort'),
    );
    _defaultCommentSort = parseEnum(
      CommentSort.values,
      CommentSort.hot,
      prefs.getString("defaultCommentSort"),
    );

    _useAccountLangFilter = prefs.getBool("useAccountLangFilter") != null
        ? prefs.getBool("useAccountLangFilter")!
        : true;
    _langFilter = prefs.getStringList("langFilter") != null
        ? prefs.getStringList("langFilter")!.toSet()
        : {};
    _defaultCreateLang = prefs.getString("defaultCreateLang") != null
        ? prefs.getString("defaultCreateLang")!
        : 'en';

    _servers = (jsonDecode(prefs.getString('servers') ??
            '{"kbin.earth":{"software":"mbin"}}') as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, Server.fromJson(value)));
    _accounts = (jsonDecode(prefs.getString('accounts') ?? '{"@kbin.earth":{}}')
            as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, Account.fromJson(value)));
    _selectedAccount = prefs.getString('selectedAccount') ?? '@kbin.earth';
    await updateAPI();

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

  Future<void> updateUseDynamicColor(bool? newUseDynamicColor) async {
    if (newUseDynamicColor == null) return;
    if (newUseDynamicColor == _useDynamicColor) return;

    _useDynamicColor = newUseDynamicColor;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDynamicColor', newUseDynamicColor);
  }

  Future<void> updateAccentColor(String? newThemeAccent) async {
    if (newThemeAccent == null) return;
    if (newThemeAccent == _accentColor) return;

    _accentColor = newThemeAccent;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accentColor', newThemeAccent);
  }

  Future<void> updateAlwaysShowInstance(bool? newShowDisplayInstance) async {
    if (newShowDisplayInstance == null) return;
    if (newShowDisplayInstance == _alwaysShowInstance) return;

    _alwaysShowInstance = newShowDisplayInstance;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alwaysShowInstance', newShowDisplayInstance);
  }

  Future<void> updatePostLayout(PostLayout? newPostLayout) async {
    if (newPostLayout == null) return;
    if (newPostLayout == _postLayout) return;

    _postLayout = newPostLayout;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('postLayout', newPostLayout.name);
  }

  Future<void> updateDefaultFeedType(PostType? newDefaultFeedMode) async {
    if (newDefaultFeedMode == null) return;
    if (newDefaultFeedMode == _defaultFeedType) return;

    _defaultFeedType = newDefaultFeedMode;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultFeedType', newDefaultFeedMode.name);
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

  Future<void> updateUseAccountLangFilter(
    bool? newUseAccountLangFilter,
  ) async {
    if (newUseAccountLangFilter == null) return;
    if (newUseAccountLangFilter == _useAccountLangFilter) return;

    _useAccountLangFilter = newUseAccountLangFilter;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useAccountLangFilter', newUseAccountLangFilter);
  }

  Future<void> addLangFilter(
    String? newLangFilter,
  ) async {
    if (newLangFilter == null) return;
    if (_langFilter.contains(newLangFilter)) return;

    _langFilter.add(newLangFilter);

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('langFilter', _langFilter.toList());
  }

  Future<void> removeLangFilter(
    String? oldLangFilter,
  ) async {
    if (oldLangFilter == null) return;
    if (!_langFilter.contains(oldLangFilter)) return;

    _langFilter.remove(oldLangFilter);

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('langFilter', _langFilter.toList());
  }

  Future<void> updateDefaultCreateLang(
    String? newDefaultCreateLang,
  ) async {
    if (newDefaultCreateLang == null) return;
    if (newDefaultCreateLang == _defaultCreateLang) return;

    _defaultCreateLang = newDefaultCreateLang;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultCreateLang', newDefaultCreateLang);
  }

  Future<void> saveServer(ServerSoftware software, String server) async {
    if (_servers.containsKey(server) &&
        _servers[server]!.software == software) {
      return;
    }

    _servers[server] = Server(software);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('servers', jsonEncode(_servers));
  }

  Future<String> getKbinOAuthIdentifier(
      ServerSoftware software, String server) async {
    if (_servers.containsKey(server) &&
        _servers[server]!.oauthIdentifier != null) {
      return _servers[server]!.oauthIdentifier!;
    }

    if (software == ServerSoftware.lemmy) {
      throw Exception('Tried to register oauth for lemmy');
    }

    String oauthIdentifier = await registerOauthApp(server);
    _servers[server] = Server(software, oauthIdentifier: oauthIdentifier);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('servers', jsonEncode(_servers));

    return oauthIdentifier;
  }

  Future<void> setAccount(
    String key,
    Account value, {
    bool switchNow = false,
  }) async {
    _accounts[key] = value;

    if (switchNow) {
      _selectedAccount = key;
    }

    updateAPI();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accounts', jsonEncode(_accounts));
    if (switchNow) {
      await prefs.setString('selectedAccount', key);
    }
  }

  Future<void> removeOAuthCredentials(String key) async {
    if (!_accounts.containsKey(key)) return;

    _accounts.remove(key);
    _selectedAccount = _accounts.keys.firstOrNull ?? '@kbin.earth';

    updateAPI();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accounts', jsonEncode(_accounts));
    await prefs.setString('selectedAccount', _selectedAccount);
  }

  Future<void> setSelectedAccount(String? newSelectedAccount) async {
    if (newSelectedAccount == null) return;
    if (newSelectedAccount == _selectedAccount) return;

    _selectedAccount = newSelectedAccount;
    updateAPI();

    userMentionCache.clear();
    magazineMentionCache.clear();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', newSelectedAccount);
  }

  Future<void> updateAPI() async {
    http.Client httpClient = http.Client();

    switch (serverSoftware) {
      case ServerSoftware.kbin:
      case ServerSoftware.mbin:
        oauth2.Credentials? credentials = _accounts[_selectedAccount]!.oauth;
        if (credentials != null) {
          String identifier = _servers[instanceHost]!.oauthIdentifier!;
          httpClient = oauth2.Client(
            credentials,
            identifier: identifier,
            onCredentialsRefreshed: (newCredentials) async {
              _accounts[_selectedAccount] = Account(oauth: newCredentials);

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setString('accounts', jsonEncode(_accounts));
            },
          );
        }
        break;
      case ServerSoftware.lemmy:
        String? jwt = _accounts[_selectedAccount]!.jwt;
        if (jwt != null) {
          httpClient = JwtHttpClient(jwt);
        }
        break;
      default:
    }

    _api = API(serverSoftware, httpClient, instanceHost);
  }

  Future<void> updateFeedActionBackToTop(ActionLocation? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionBackToTop) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionBackToTop = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionBackToTop', newLocation.name);
  }

  Future<void> updateFeedActionCreatePost(ActionLocation? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionCreatePost) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionCreatePost = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionCreatePost', newLocation.name);
  }

  Future<void> updateFeedActionExpandFab(ActionLocation? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionExpandFab) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionExpandFab = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionExpandFab', newLocation.name);
  }

  Future<void> updateFeedActionRefresh(ActionLocation? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionRefresh) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionRefresh = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionRefresh', newLocation.name);
  }

  Future<void> updateFeedActionSetFilter(
      ActionLocationWithTabs? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionSetFilter) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionSetFilter = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionSetFilter', newLocation.name);
  }

  Future<void> updateFeedActionSetSort(ActionLocation? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionSetSort) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionSetSort = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionSetSort', newLocation.name);
  }

  Future<void> updateFeedActionSetType(
      ActionLocationWithTabs? newLocation) async {
    if (newLocation == null) return;
    if (newLocation == _feedActionSetType) return;

    removeDuplicateFeedAction(newLocation.name);

    _feedActionSetType = newLocation;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedActionSetType', newLocation.name);
  }

  Future<void> removeDuplicateFeedAction(String checkLocation) async {
    if ([
      ActionLocation.hide.name,
      ActionLocation.appBar.name,
      ActionLocation.fabMenu.name,
    ].contains(checkLocation)) return;

    if (_feedActionBackToTop.name == checkLocation) {
      updateFeedActionBackToTop(ActionLocation.hide);
    }
    if (_feedActionCreatePost.name == checkLocation) {
      updateFeedActionCreatePost(ActionLocation.hide);
    }
    if (_feedActionExpandFab.name == checkLocation) {
      updateFeedActionExpandFab(ActionLocation.hide);
    }
    if (_feedActionRefresh.name == checkLocation) {
      updateFeedActionRefresh(ActionLocation.hide);
    }
    if (_feedActionSetFilter.name == checkLocation) {
      updateFeedActionSetFilter(ActionLocationWithTabs.hide);
    }
    if (_feedActionSetSort.name == checkLocation) {
      updateFeedActionSetSort(ActionLocation.hide);
    }
    if (_feedActionSetType.name == checkLocation) {
      updateFeedActionSetType(ActionLocationWithTabs.hide);
    }
  }
}
