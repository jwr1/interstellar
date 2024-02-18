import 'package:flutter/material.dart';
import 'package:interstellar/src/models/old/user.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class SelfFeed extends StatefulWidget {
  const SelfFeed({super.key});

  @override
  State<SelfFeed> createState() => _SelfFeedState();
}

class _SelfFeedState extends State<SelfFeed> {
  DetailedUserModel? _meUser;

  @override
  void initState() {
    super.initState();

    if (context.read<SettingsController>().isLoggedIn) {
      context
          .read<SettingsController>()
          .kbinAPI
          .users
          .getMe()
          .then((value) => setState(() {
                _meUser = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_meUser == null)
        ? const Center(child: CircularProgressIndicator())
        : UserScreen(
            _meUser!.userId,
            initData: _meUser,
          );
  }
}
