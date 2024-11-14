import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

Future<void> switchAccount(BuildContext context, String oldAccount) async {
  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return AccountSelectWidget(oldAccount: oldAccount);
    },
  );
}

Future<String?> selectAccountWithNone(
    BuildContext context, String oldAccount) async {
  return await showModalBottomSheet<String>(
    context: context,
    builder: (BuildContext context) {
      return AccountSelectWidget(oldAccount: oldAccount, showNoneOption: true);
    },
  );
}

class AccountSelectWidget extends StatefulWidget {
  final bool showNoneOption;
  final bool showAccountControls;
  final String oldAccount;

  const AccountSelectWidget({
    this.showNoneOption = false,
    this.showAccountControls = false,
    required this.oldAccount,
    super.key,
  });

  @override
  State<AccountSelectWidget> createState() => _AccountSelectWidgetState();
}

class _AccountSelectWidgetState extends State<AccountSelectWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.watch<AppController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l(context).account_switch,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          child: ListView(shrinkWrap: true, children: [
            ListTile(
              title: Text(l(context).profile_autoSelectAccount_none),
              onTap: () async {
                Navigator.of(context).pop('');
              },
            ),
            ...ac.accounts.keys.map(
              (account) => ListTile(
                title: Text(account),
                onTap: () async {
                  Navigator.of(context).pop(account);
                },
                selected: account == widget.oldAccount,
                selectedTileColor: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ],
    );
  }
}
