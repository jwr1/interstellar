import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/api/api.dart';
import 'package:interstellar/src/api/oauth.dart';
import 'package:interstellar/src/controller/account.dart';
import 'package:interstellar/src/controller/database.dart';
import 'package:interstellar/src/controller/profile.dart';
import 'package:interstellar/src/controller/server.dart';
import 'package:interstellar/src/utils/jwt_http_client.dart';
import 'package:interstellar/src/widgets/markdown/markdown_mention.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:sembast/sembast_io.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:webpush_encryption/webpush_encryption.dart';

class AppController with ChangeNotifier {
  final _mainStore = StoreRef.main();
  final _accountStore = StoreRef<String, Map<String, Object?>>('account');
  final _profileStore = StoreRef<String, Map<String, Object?>>('profile');
  final _serverStore = StoreRef<String, Map<String, Object?>>('server');

  late final _mainProfileRecord = _mainStore.record('mainProfile');
  late final _selectedProfileRecord = _mainStore.record('selectedProfile');

  late final _selectedAccountRecord = _mainStore.record('selectedAccount');
  late final _starsRecord = _mainStore.record('stars');
  late final _webPushKeysRecord = _mainStore.record('webPushKeys');

  late String _mainProfile;
  late String _selectedProfile;

  late ProfileRequired _builtProfile;
  ProfileRequired get profile => _builtProfile;

  late ProfileOptional _selectedProfileValue;
  ProfileOptional get selectedProfileValue => _selectedProfileValue;

  late List<String> _stars;
  List<String> get stars => _stars;

  late WebPushKeys _webPushKeys;
  WebPushKeys get webPushKeys => _webPushKeys;

  bool get isPushRegistered =>
      _accounts[_selectedAccount]?.isPushRegistered ?? false;

  late Map<String, Server> _servers;
  late Map<String, Account> _accounts;
  late API _api;

  Map<String, Server> get servers => _servers;
  Map<String, Account> get accounts => _accounts;
  late String _selectedAccount;
  String get selectedAccount => _selectedAccount;
  String get instanceHost => _selectedAccount.split('@').last;
  bool get isLoggedIn => _selectedAccount.split('@').first.isNotEmpty;
  ServerSoftware get serverSoftware => _servers[instanceHost]!.software;
  API get api => _api;

  Future<void> init() async {
    _mainProfile = await _mainProfileRecord.get(db) as String? ?? 'Default';
    _selectedProfile =
        await _selectedProfileRecord.get(db) as String? ?? 'Default';

    _rebuildProfile();

    _stars = (await _starsRecord.get(db) as List<Object?>? ?? [])
        .map((v) => v as String)
        .toList();

    final webPushKeysValue = await _webPushKeysRecord.get(db) as String?;
    if (webPushKeysValue != null) {
      _webPushKeys = await WebPushKeys.deserialize(webPushKeysValue);
    } else {
      _webPushKeys = await WebPushKeys.newKeyPair();
      await _webPushKeysRecord.put(db, _webPushKeys.serialize);
    }

    _servers = Map.fromEntries((await _serverStore.find(db))
        .map((record) => MapEntry(record.key, Server.fromJson(record.value))));
    if (_servers.isEmpty) {
      _servers['kbin.earth'] = const Server(software: ServerSoftware.mbin);
    }
    _selectedAccount =
        await _selectedAccountRecord.get(db) as String? ?? '@kbin.earth';

    _accounts = Map.fromEntries((await _accountStore.find(db))
        .map((record) => MapEntry(record.key, Account.fromJson(record.value))));
    if (_accounts.isEmpty) {
      _accounts['@kbin.earth'] = const Account();
    }

    await _updateAPI();
  }

  Future<void> _rebuildProfile() async {
    final records = _profileStore.records(
        [FieldKey.escape(_mainProfile), FieldKey.escape(_selectedProfile)]);

    final [mainRecord, selectedRecord] = await records.get(db);
    final mainProfile =
        mainRecord == null ? null : ProfileOptional.fromJson(mainRecord);
    final selectedProfile = selectedRecord == null
        ? null
        : ProfileOptional.fromJson(selectedRecord);

    _selectedProfileValue = selectedProfile ?? ProfileOptional.nullProfile;

    _builtProfile =
        ProfileRequired.fromOptional(mainProfile?.merge(selectedProfile));
  }

  Future<void> updateProfile(ProfileOptional value) async {
    final record = _profileStore.record(FieldKey.escape(_selectedProfile));
    await record.put(db, value.toJson());

    await _rebuildProfile();

    notifyListeners();
  }

  Future<void> switchProfiles(String? newProfile) async {
    if (newProfile == null) return;
    if (newProfile == _selectedProfile) return;

    _selectedProfile = newProfile;
    await _selectedProfileRecord.put(db, _selectedProfile);

    await _rebuildProfile();

    notifyListeners();
  }

  Future<void> saveServer(ServerSoftware software, String server) async {
    if (_servers.containsKey(server) &&
        _servers[server]!.software == software) {
      return;
    }

    _servers[server] = Server(software: software);

    await _serverStore.record(server).put(db, _servers[server]!.toJson());
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
    _servers[server] =
        Server(software: software, oauthIdentifier: oauthIdentifier);

    await _serverStore.record(server).put(db, _servers[server]!.toJson());

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
      await _selectedAccountRecord.put(db, _selectedAccount);
    }

    _updateAPI();

    notifyListeners();

    await _accountStore.record(key).put(db, _accounts[key]!.toJson());
  }

  Future<void> removeAccount(String key) async {
    if (!_accounts.containsKey(key)) return;

    try {
      if (_accounts[key]!.isPushRegistered ?? false) await unregisterPush(key);
    } catch (e) {
      // Ignore error in case unregister fails so the account is still removed
    }

    _accounts.remove(key);
    _selectedAccount = _accounts.keys.firstOrNull ?? '@kbin.earth';

    _updateAPI();

    notifyListeners();

    await _accountStore.record(key).delete(db);
    await _selectedAccountRecord.put(db, _selectedAccount);
  }

  Future<void> switchAccounts(String? newAccount) async {
    if (newAccount == null) return;
    if (newAccount == _selectedAccount) return;

    _selectedAccount = newAccount;
    _updateAPI();

    userMentionCache.clear();
    magazineMentionCache.clear();

    notifyListeners();

    await _selectedAccountRecord.put(db, _selectedAccount);
  }

  Future<void> _updateAPI() async {
    _api = await getApiForAccount(_selectedAccount);
  }

  Future<API> getApiForAccount(String account) async {
    final instance = account.split('@').last;

    http.Client httpClient = http.Client();

    switch (serverSoftware) {
      case ServerSoftware.mbin:
        oauth2.Credentials? credentials = _accounts[account]?.oauth;
        if (credentials != null) {
          String identifier = _servers[instance]!.oauthIdentifier!;
          httpClient = oauth2.Client(
            credentials,
            identifier: identifier,
            onCredentialsRefreshed: (newCredentials) async {
              _accounts[account] =
                  _accounts[account]!.copyWith(oauth: newCredentials);

              await _accountStore
                  .record(account)
                  .put(db, _accounts[account]!.toJson());
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

  Future<void> addStar(String newStar) async {
    if (_stars.contains(newStar)) return;

    _stars.add(newStar);

    notifyListeners();

    await _starsRecord.put(db, _stars);
  }

  Future<void> removeStar(String oldStar) async {
    if (!_stars.contains(oldStar)) return;

    _stars.remove(oldStar);

    notifyListeners();

    await _starsRecord.put(db, _stars);
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
      _selectedAccount,
      [featureAndroidBytesMessage],
    );

    await addPushRegistrationStatus(_selectedAccount);
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
    _accounts[account] = _accounts[account]!.copyWith(isPushRegistered: true);

    notifyListeners();

    await _accountStore.record(account).put(db, _accounts[account]!.toJson());
  }

  Future<void> removePushRegistrationStatus(String account) async {
    _accounts[account] = _accounts[account]!.copyWith(isPushRegistered: false);

    notifyListeners();

    await _accountStore.record(account).put(db, _accounts[account]!.toJson());
  }
}
