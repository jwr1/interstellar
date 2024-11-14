import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/controller/profile.dart';
import 'package:interstellar/src/screens/settings/account_selection.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/list_tile_switch.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

Future<void> switchProfileSelect(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return const _ProfileSelectWidget();
    },
  );
}

class _ProfileSelectWidget extends StatefulWidget {
  const _ProfileSelectWidget({super.key});

  @override
  State<_ProfileSelectWidget> createState() => _ProfileSelectWidgetState();
}

class _ProfileSelectWidgetState extends State<_ProfileSelectWidget> {
  List<String>? profileList;

  void getProfiles() async {
    final profileNames = await context.read<AppController>().getProfileNames();
    setState(() {
      profileList = profileNames;
    });
  }

  @override
  void initState() {
    super.initState();

    getProfiles();
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
            l(context).profile_switch,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        if (profileList != null)
          Flexible(
            child: ListView(shrinkWrap: true, children: [
              ...profileList!.map(
                (profile) => ListTile(
                  title: Text(profile),
                  subtitle: profile == ac.mainProfile
                      ? Text(l(context).profile_main)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    await ac.switchProfiles(profile);
                  },
                  selected: profile == ac.selectedProfile,
                  selectedTileColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.2),
                  trailing: IconButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _EditProfileScreen(
                              profile: profile,
                              profileList: profileList!,
                            ),
                          ),
                        );
                        getProfiles();
                      },
                      icon: const Icon(Symbols.edit_rounded)),
                ),
              ),
              ListTile(
                leading: const Icon(Symbols.add_rounded),
                title: Text(l(context).profile_new),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => _EditProfileScreen(
                        profile: null,
                        profileList: profileList!,
                      ),
                    ),
                  );
                  getProfiles();
                },
              ),
              const SizedBox(height: 16),
            ]),
          ),
      ],
    );
  }
}

class _EditProfileScreen extends StatefulWidget {
  final String? profile;
  final List<String> profileList;

  const _EditProfileScreen({
    required this.profile,
    required this.profileList,
    super.key,
  });

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  final nameController = TextEditingController();

  bool setAsMain = false;

  bool? oldAutoSelect;
  bool newAutoSelect = false;

  String? autoSelectAccount;

  @override
  void initState() {
    super.initState();

    if (widget.profile != null) {
      nameController.text = widget.profile!;
      newAutoSelect =
          widget.profile == context.read<AppController>().autoSelectProfile;
      oldAutoSelect = newAutoSelect;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ac = context.watch<AppController>();
    final isMainProfile = widget.profile == ac.mainProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null
            ? l(context).profile_new
            : l(context).profile_edit),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextEditor(
            nameController,
            label: l(context).profile_name,
            onChanged: (_) => setState(() {}),
          ),
          ListTileSwitch(
            title: Text(l(context).profile_setAsMain),
            subtitle: Text(l(context).profile_setAsMain_help),
            value: isMainProfile || setAsMain,
            onChanged: isMainProfile
                ? null
                : (newValue) => setState(() {
                      setAsMain = newValue;
                    }),
          ),
          ListTileSwitch(
            title: Text(l(context).profile_autoSelect),
            value: newAutoSelect,
            onChanged: (newValue) => setState(() {
              newAutoSelect = newValue;
            }),
          ),
          ListTile(
            title: Text(l(context).profile_autoSelectAccount),
            subtitle: Text(
                autoSelectAccount ?? l(context).profile_autoSelectAccount_none),
            onTap: () async {
              final newAutoSelectAccount =
                  await selectAccountWithNone(context, autoSelectAccount ?? '');

              if (newAutoSelectAccount == null) return;

              setState(() {
                autoSelectAccount =
                    newAutoSelectAccount.isEmpty ? null : newAutoSelectAccount;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LoadingFilledButton(
              icon: const Icon(Symbols.save_rounded),
              onPressed: nameController.text.isEmpty ||
                      (nameController.text != widget.profile &&
                          widget.profileList.contains(nameController.text))
                  ? null
                  : () async {
                      if (widget.profile == null) {
                        await ac.setProfile(
                          nameController.text,
                          ProfileOptional.nullProfile,
                        );
                      } else if (nameController.text != widget.profile) {
                        await ac.renameProfile(
                            widget.profile!, nameController.text);
                      }

                      if (setAsMain) {
                        await ac.setMainProfile(nameController.text);
                      }

                      if (oldAutoSelect != newAutoSelect) {
                        await ac.setAutoSelectProfile(
                            newAutoSelect ? nameController.text : null);
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              label: Text(l(context).saveChanges),
            ),
          ),
          if (widget.profile != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                icon: const Icon(Symbols.delete_rounded),
                onPressed: widget.profile == ac.mainProfile
                    ? null
                    : () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(l(context).profile_delete),
                            content: Text(widget.profile!),
                            actions: <Widget>[
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l(context).cancel),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  await ac.deleteProfile(widget.profile!);

                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(l(context).delete),
                              ),
                            ],
                          ),
                        );
                      },
                label: Text(l(context).profile_delete),
              ),
            ),
        ],
      ),
    );
  }
}
