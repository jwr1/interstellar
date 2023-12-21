import 'package:flutter/material.dart';
import 'package:interstellar/src/api/users.dart' as api_users;
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool? _loggedIn;
  api_users.DetailedUser? _meUser;

  @override
  void initState() {
    super.initState();

    _loggedIn = context
        .read<SettingsController>()
        .selectedAccount
        .split('@')
        .first
        .isNotEmpty;

    if (_loggedIn!) {
      api_users
          .fetchMe(context.read<SettingsController>().httpClient,
              context.read<SettingsController>().instanceHost)
          .then((value) => setState(() {
                _meUser = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loggedIn == null || (_loggedIn == true && _meUser == null)
        ? const Center(child: CircularProgressIndicator())
        : (_loggedIn!
            ? UserScreen(
                _meUser!.userId,
                data: _meUser,
              )
            : const Center(
                child: Text('Not logged in'),
              ));
  }
}
