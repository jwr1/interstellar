import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:interstellar/src/widgets/markdown/markdown_mention.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:webpush_encryption/webpush_encryption.dart';

enum ServerSoftware { mbin, lemmy }

enum PostImagePosition { auto, top, right }

class Server {
  final ServerSoftware software;
  final String? oauthIdentifier;

  Server(this.software, {this.oauthIdentifier});

  factory Server.fromJson(Map<String, Object?> json) => Server(
        ServerSoftware.values.byName(json['software'] as String == 'kbin'
            ? 'mbin'
            : json['software'] as String),
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
  late bool _enableTrueBlack;
  bool get enableTrueBlack => _enableTrueBlack;
  late bool _useDynamicColor;
  bool get useDynamicColor => _useDynamicColor;
  late String _accentColor;
  String get accentColor => _accentColor;
  ThemeInfo get theme =>
      themes.firstWhere((theme) => theme.name == _accentColor);

  late PostImagePosition _postImagePosition;
  PostImagePosition get postImagePosition => _postImagePosition;
  late bool _postCompactPreview;
  bool get postCompactPreview => _postCompactPreview;

  late bool _alwaysShowInstance;
  bool get alwaysShowInstance => _alwaysShowInstance;

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
  late FeedSource _defaultFeedFilter;
  FeedSource get defaultFeedFilter => _defaultFeedFilter;
  late FeedSort _defaultThreadsFeedSort;
  FeedSort get defaultThreadsFeedSort => _defaultThreadsFeedSort;
  late FeedSort _defaultMicroblogFeedSort;
  FeedSort get defaultMicroblogFeedSort => _defaultMicroblogFeedSort;
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

  late Set<String> _stars;
  Set<String> get stars => _stars;

  late Set<String> _feedFilters;
  Set<String> get feedFilters => _feedFilters;
  late Set<RegExp> _feedFiltersRegExp;
  Set<RegExp> get feedFiltersRegExp => _feedFiltersRegExp;

  void _regenerateFeedFiltersRegExp() {
    _feedFiltersRegExp = _feedFilters
        .map((filter) => RegExp(filter, caseSensitive: false))
        .toSet();
  }

  late WebPushKeys _webPushKeys;
  WebPushKeys get webPushKeys => _webPushKeys;

  late Set<String> _pushRegistrations;
  bool get isPushRegistered => _pushRegistrations.contains(selectedAccount);

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
      prefs.getString('themeMode'),
    );
    _enableTrueBlack = prefs.getBool('enableTrueBlack') ?? false;
    _useDynamicColor = prefs.getBool('useDynamicColor') ?? true;
    _accentColor = prefs.getString('accentColor') ?? 'Default';

    _alwaysShowInstance = prefs.getBool('alwaysShowInstance') ?? false;

    _postImagePosition = parseEnum(
      PostImagePosition.values,
      PostImagePosition.auto,
      prefs.getString('postImagePosition'),
    );
    _postCompactPreview = prefs.getBool('postCompactPreview') ?? false;

    _feedActionBackToTop = parseEnum(
      ActionLocation.values,
      ActionLocation.fabMenu,
      prefs.getString('feedActionBackToTop'),
    );
    _feedActionCreatePost = parseEnum(
      ActionLocation.values,
      ActionLocation.fabMenu,
      prefs.getString('feedActionCreatePost'),
    );
    _feedActionExpandFab = parseEnum(
      ActionLocation.values,
      ActionLocation.fabTap,
      prefs.getString('feedActionExpandFab'),
    );
    _feedActionRefresh = parseEnum(
      ActionLocation.values,
      ActionLocation.fabMenu,
      prefs.getString('feedActionRefresh'),
    );
    _feedActionSetFilter = parseEnum(
      ActionLocationWithTabs.values,
      ActionLocationWithTabs.tabs,
      prefs.getString('feedActionSetFilter'),
    );
    _feedActionSetSort = parseEnum(
      ActionLocation.values,
      ActionLocation.appBar,
      prefs.getString('feedActionSetSort'),
    );
    _feedActionSetType = parseEnum(
      ActionLocationWithTabs.values,
      ActionLocationWithTabs.appBar,
      prefs.getString('feedActionSetType'),
    );

    _defaultFeedType = parseEnum(
      PostType.values,
      PostType.thread,
      prefs.getString('defaultFeedType'),
    );
    _defaultFeedFilter = parseEnum(
      FeedSource.values,
      FeedSource.subscribed,
      prefs.getString('defaultFeedFilter'),
    );
    _defaultThreadsFeedSort = parseEnum(
      FeedSort.values,
      FeedSort.hot,
      prefs.getString('defaultThreadsFeedSort'),
    );
    _defaultMicroblogFeedSort = parseEnum(
      FeedSort.values,
      FeedSort.hot,
      prefs.getString('defaultMicroblogFeedSort'),
    );
    _defaultExploreFeedSort = parseEnum(
      FeedSort.values,
      FeedSort.hot,
      prefs.getString('defaultExploreFeedSort'),
    );
    _defaultCommentSort = parseEnum(
      CommentSort.values,
      CommentSort.hot,
      prefs.getString('defaultCommentSort'),
    );

    _useAccountLangFilter = prefs.getBool('useAccountLangFilter') ?? true;
    _langFilter = prefs.getStringList('langFilter')?.toSet() ?? {};
    _defaultCreateLang = prefs.getString('defaultCreateLang') ?? 'en';

    _stars = prefs.getStringList('stars')?.toSet() ?? {};

    _feedFilters = prefs.getStringList('feedFilters')?.toSet() ?? {};
    _regenerateFeedFiltersRegExp();

    if (prefs.getString('webPushKeys') != null) {
      _webPushKeys =
          await WebPushKeys.deserialize(prefs.getString('webPushKeys')!);
    } else {
      _webPushKeys = await WebPushKeys.newKeyPair();
      await prefs.setString('webPushKeys', _webPushKeys.serialize);
    }

    _pushRegistrations =
        prefs.getStringList('pushRegistrations')?.toSet() ?? {};

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

  Future<void> updateThemeMode(ThemeMode? newValue) async {
    if (newValue == null) return;
    if (newValue == _themeMode) return;

    _themeMode = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newValue.name);
  }

  Future<void> updateEnableTrueBlack(bool? newValue) async {
    if (newValue == null) return;
    if (newValue == _enableTrueBlack) return;

    _enableTrueBlack = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableTrueBlack', newValue);
  }

  Future<void> updateUseDynamicColor(bool? newValue) async {
    if (newValue == null) return;
    if (newValue == _useDynamicColor) return;

    _useDynamicColor = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDynamicColor', newValue);
  }

  Future<void> updateAccentColor(String? newValue) async {
    if (newValue == null) return;
    if (newValue == _accentColor) return;

    _accentColor = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accentColor', newValue);
  }

  Future<void> updatePostImagePosition(PostImagePosition? newValue) async {
    if (newValue == null) return;
    if (newValue == _postImagePosition) return;

    _postImagePosition = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('postImagePosition', newValue.name);
  }

  Future<void> updatePostCompactPreview(bool? newValue) async {
    if (newValue == null) return;
    if (newValue == _postCompactPreview) return;

    _postCompactPreview = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('postCompactPreview', newValue);
  }

  Future<void> updateAlwaysShowInstance(bool? newValue) async {
    if (newValue == null) return;
    if (newValue == _alwaysShowInstance) return;

    _alwaysShowInstance = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alwaysShowInstance', newValue);
  }

  Future<void> updateDefaultFeedType(PostType? newValue) async {
    if (newValue == null) return;
    if (newValue == _defaultFeedType) return;

    _defaultFeedType = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultFeedType', newValue.name);
  }

  Future<void> updateDefaultFeedFilter(FeedSource? newValue) async {
    if (newValue == null) return;
    if (newValue == _defaultFeedFilter) return;

    _defaultFeedFilter = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultFeedFilter', newValue.name);
  }

  Future<void> updateDefaultThreadsFeedSort(FeedSort? newValue) async {
    if (newValue == null) return;
    if (newValue == _defaultThreadsFeedSort) return;

    _defaultThreadsFeedSort = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultThreadsFeedSort', newValue.name);
  }

  Future<void> updateDefaultMicroblogFeedSort(FeedSort? newValue) async {
    if (newValue == null) return;
    if (newValue == _defaultMicroblogFeedSort) return;

    _defaultMicroblogFeedSort = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultMicroblogFeedSort', newValue.name);
  }

  Future<void> updateDefaultExploreFeedSort(
    FeedSort? newValue,
  ) async {
    if (newValue == null) return;
    if (newValue == _defaultExploreFeedSort) return;

    _defaultExploreFeedSort = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultExploreFeedSort', newValue.name);
  }

  Future<void> updateDefaultCommentSort(
    CommentSort? newValue,
  ) async {
    if (newValue == null) return;
    if (newValue == _defaultCommentSort) return;

    _defaultCommentSort = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultCommentSort', newValue.name);
  }

  Future<void> updateUseAccountLangFilter(
    bool? newValue,
  ) async {
    if (newValue == null) return;
    if (newValue == _useAccountLangFilter) return;

    _useAccountLangFilter = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useAccountLangFilter', newValue);
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
    String? newValue,
  ) async {
    if (newValue == null) return;
    if (newValue == _defaultCreateLang) return;

    _defaultCreateLang = newValue;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultCreateLang', newValue);
  }

  Future<void> addStar(
    String? newStar,
  ) async {
    if (newStar == null) return;
    if (_stars.contains(newStar)) return;

    _stars.add(newStar);

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stars', _stars.toList());
  }

  Future<void> removeStar(
    String? oldStar,
  ) async {
    if (oldStar == null) return;
    if (!_stars.contains(oldStar)) return;

    _stars.remove(oldStar);

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stars', _stars.toList());
  }

  Future<void> addFeedFilter(
    String? newFilter,
  ) async {
    if (newFilter == null) return;
    if (_feedFilters.contains(newFilter)) return;

    _feedFilters.add(newFilter);
    _regenerateFeedFiltersRegExp();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('feedFilters', _feedFilters.toList());
  }

  Future<void> removeFeedFilter(String? oldFilter) async {
    if (oldFilter == null) return;
    if (!_feedFilters.contains(oldFilter)) return;

    _feedFilters.remove(oldFilter);
    _regenerateFeedFiltersRegExp();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('feedFilters', _feedFilters.toList());
  }

  Future<void> registerPush(BuildContext context) async {
    if (serverSoftware != ServerSoftware.mbin) {
      throw Exception('Push notifications only supported on Mbin');
    }

    final permissionsResult = await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (permissionsResult == false) {
      throw Exception('Notification permissions denied');
    }

    await UnifiedPush.registerAppWithDialog(
      context,
      selectedAccount,
      [featureAndroidBytesMessage],
    );

    await addPushRegistrationStatus(selectedAccount);
  }

  Future<void> unregisterPush([String? overrideAccount]) async {
    if (serverSoftware != ServerSoftware.mbin) {
      throw Exception('Push notifications only supported on Mbin');
    }

    final account = overrideAccount ?? _selectedAccount;

    await UnifiedPush.unregister(account);

    // When unregistering a non selected account, make sure the api uses the correct
    // authentication for the target account, instead of the currently selected account.
    await (account == _selectedAccount ? api : await getApiForAccount(account))
        .notifications
        .pushDelete();

    removePushRegistrationStatus(account);
  }

  Future<void> addPushRegistrationStatus(String account) async {
    _pushRegistrations.add(account);

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pushRegistrations', _pushRegistrations.toList());
  }

  Future<void> removePushRegistrationStatus(String account) async {
    _pushRegistrations.remove(account);

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pushRegistrations', _pushRegistrations.toList());
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

  Future<String> getMbinOAuthIdentifier(
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

  Future<void> removeAccount(String key) async {
    if (!_accounts.containsKey(key)) return;

    if (_pushRegistrations.contains(key)) await unregisterPush(key);

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

  Future<API> getApiForAccount(String account) async {
    final instance = account.split('@').last;

    http.Client httpClient = http.Client();

    switch (serverSoftware) {
      case ServerSoftware.mbin:
        oauth2.Credentials? credentials = _accounts[account]!.oauth;
        if (credentials != null) {
          String identifier = _servers[instance]!.oauthIdentifier!;
          httpClient = oauth2.Client(
            credentials,
            identifier: identifier,
            onCredentialsRefreshed: (newCredentials) async {
              _accounts[account] = Account(oauth: newCredentials);

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setString('accounts', jsonEncode(_accounts));
            },
          );
        }
        break;
      case ServerSoftware.lemmy:
        String? jwt = _accounts[account]!.jwt;
        if (jwt != null) {
          httpClient = JwtHttpClient(jwt);
        }
        break;
      default:
    }

    return API(serverSoftware, httpClient, instance);
  }

  Future<void> updateAPI() async {
    _api = await getApiForAccount(_selectedAccount);
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
