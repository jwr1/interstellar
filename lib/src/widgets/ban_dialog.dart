import 'package:flutter/material.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

Future<void> openBanDialog(
  BuildContext context, {
  required UserModel user,
  required MagazineModel magazine,
}) async {
  await showDialog<DetailedMagazineModel>(
    context: context,
    builder: (BuildContext context) =>
        BanDialog(user: user, magazine: magazine),
  );
}

class BanDialog extends StatefulWidget {
  final UserModel user;
  final MagazineModel magazine;

  const BanDialog({
    required this.user,
    required this.magazine,
    super.key,
  });

  @override
  State<BanDialog> createState() => _BanDialogState();
}

class _BanDialogState extends State<BanDialog> {
  final _reasonTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ban User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'You are about to ban ${widget.user.name} from ${widget.magazine.name}.'),
          const SizedBox(height: 16),
          TextEditor(
            _reasonTextEditingController,
            label: 'Reason',
            onChanged: (_) => setState(() {}),
          )
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _reasonTextEditingController.text.isEmpty
              ? null
              : () async {
                  await context
                      .read<SettingsController>()
                      .api
                      .magazineModeration
                      .createBan(
                        widget.magazine.id,
                        widget.user.id,
                        reason: _reasonTextEditingController.text,
                      );

                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
          child: Text('Ban ${widget.user.name}'),
        ),
      ],
    );
  }
}
