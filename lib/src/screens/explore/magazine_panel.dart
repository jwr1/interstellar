import 'package:flutter/material.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/models/user.dart';
import 'package:interstellar/src/screens/explore/user_item.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';
import 'package:interstellar/src/widgets/text_editor.dart';
import 'package:provider/provider.dart';

class MagazinePanel extends StatefulWidget {
  final DetailedMagazineModel initData;
  final void Function(DetailedMagazineModel) onUpdate;

  const MagazinePanel({
    super.key,
    required this.initData,
    required this.onUpdate,
  });

  @override
  State<MagazinePanel> createState() => _MagazinePanelState();
}

class _MagazinePanelState extends State<MagazinePanel> {
  late DetailedMagazineModel _data;

  @override
  void initState() {
    super.initState();

    _data = widget.initData;
  }

  @override
  Widget build(BuildContext context) {
    onUpdate(DetailedMagazineModel newValue) {
      setState(() {
        _data = newValue;
        widget.onUpdate(newValue);
      });
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Magazine Panel for ${widget.initData.name}'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: 'General'),
                Tab(text: 'Moderators'),
                Tab(text: 'Deletion'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              MagazinePanelGeneral(data: _data, onUpdate: onUpdate),
              MagazinePanelModerators(data: _data, onUpdate: onUpdate),
              MagazinePanelDeletion(data: _data, onUpdate: onUpdate),
            ],
          )),
    );
  }
}

class MagazinePanelGeneral extends StatefulWidget {
  final DetailedMagazineModel data;
  final void Function(DetailedMagazineModel) onUpdate;

  const MagazinePanelGeneral({
    super.key,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<MagazinePanelGeneral> createState() => _MagazinePanelGeneralState();
}

class _MagazinePanelGeneralState extends State<MagazinePanelGeneral> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late bool _isAdult;
  late bool _isPostingRestrictedToMods;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.data.title;
    _descriptionController.text = widget.data.description ?? '';

    _isAdult = widget.data.isAdult;
    _isPostingRestrictedToMods = widget.data.isPostingRestrictedToMods;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TextEditor(
            _titleController,
            label: 'Title',
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: MarkdownEditor(
            _descriptionController,
            label: 'Description',
            originInstance: getNameHost(context, widget.data.name),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Is adult'),
                value: _isAdult,
                onChanged: (bool value) {
                  setState(() {
                    _isAdult = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Is posting restricted to mods'),
                value: _isPostingRestrictedToMods,
                onChanged: (bool value) {
                  setState(() {
                    _isPostingRestrictedToMods = value;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: FilledButton(
              onPressed: _titleController.text == widget.data.title &&
                      _descriptionController.text == widget.data.description &&
                      _isAdult == widget.data.isAdult &&
                      _isPostingRestrictedToMods ==
                          widget.data.isPostingRestrictedToMods
                  ? null
                  : () async {
                      final result = await context
                          .read<SettingsController>()
                          .api
                          .magazineModeration
                          .edit(
                            widget.data.id,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            isAdult: _isAdult,
                            isPostingRestrictedToMods:
                                _isPostingRestrictedToMods,
                          );

                      widget.onUpdate(result);
                    },
              child: const Text('Save')),
        ),
      ],
    );
  }
}

class MagazinePanelModerators extends StatefulWidget {
  final DetailedMagazineModel data;
  final void Function(DetailedMagazineModel) onUpdate;

  const MagazinePanelModerators({
    super.key,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<MagazinePanelModerators> createState() =>
      _MagazinePanelModeratorsState();
}

class _MagazinePanelModeratorsState extends State<MagazinePanelModerators> {
  final TextEditingController _addModController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextEditor(
                _addModController,
                label: 'Add Moderator',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: _addModController.text.isEmpty
                  ? null
                  : () async {
                      final user = await context
                          .read<SettingsController>()
                          .api
                          .users
                          .getByName(_addModController.text);

                      if (!mounted) return;
                      final result = await showDialog<DetailedMagazineModel>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Add Moderator'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserItemSimple(UserModel.fromDetailedUser(user)),
                            ],
                          ),
                          actions: <Widget>[
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                Navigator.of(context).pop(
                                  await context
                                      .read<SettingsController>()
                                      .api
                                      .magazineModeration
                                      .updateModerator(
                                          widget.data.id, user.id, true),
                                );
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );

                      if (result != null) widget.onUpdate(result);
                    },
              label: const Text('Add'),
              icon: const Icon(Icons.add),
            )
          ],
        ),
        const SizedBox(height: 16),
        ...widget.data.moderators.map(
          (mod) => UserItemSimple(
            mod,
            isOwner: mod.id == widget.data.owner?.id,
            trailingWidgets: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final result = await showDialog<DetailedMagazineModel>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Remove moderator'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserItemSimple(
                            mod,
                            isOwner: mod.id == widget.data.owner?.id,
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.of(context).pop(
                              await context
                                  .read<SettingsController>()
                                  .api
                                  .magazineModeration
                                  .updateModerator(
                                      widget.data.id, mod.id, false),
                            );
                          },
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );

                  if (result != null) widget.onUpdate(result);
                },
              )
            ],
          ),
        )
      ],
    );
  }
}

class MagazinePanelDeletion extends StatefulWidget {
  final DetailedMagazineModel data;
  final void Function(DetailedMagazineModel) onUpdate;

  const MagazinePanelDeletion({
    super.key,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<MagazinePanelDeletion> createState() => _MagazinePanelDeletionState();
}

class _MagazinePanelDeletionState extends State<MagazinePanelDeletion> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: FilledButton(
            onPressed: widget.data.icon == null
                ? null
                : () async {
                    await context
                        .read<SettingsController>()
                        .api
                        .magazineModeration
                        .removeIcon(widget.data.id);

                    widget.onUpdate(widget.data.copyWith(icon: null));
                  },
            child: const Text('Remove icon'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: FilledButton(
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red)),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) =>
                    MagazinePanelDeletionDialog(data: widget.data),
              );

              if (result == true) {
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete Magazine'),
          ),
        ),
      ],
    );
  }
}

class MagazinePanelDeletionDialog extends StatefulWidget {
  final DetailedMagazineModel data;

  const MagazinePanelDeletionDialog({
    super.key,
    required this.data,
  });

  @override
  State<MagazinePanelDeletionDialog> createState() =>
      _MagazinePanelDeletionDialogState();
}

class _MagazinePanelDeletionDialogState
    extends State<MagazinePanelDeletionDialog> {
  final TextEditingController _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final magazineName = widget.data.name;

    return AlertDialog(
      title: const Text('Delete magazine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'WARNING: You are about to delete this magazine and all of its related posts. Type "$magazineName" below to confirm deletion.'),
          const SizedBox(height: 16),
          TextEditor(
            _confirmController,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirmController.text != magazineName
              ? null
              : () async {
                  await context
                      .read<SettingsController>()
                      .api
                      .magazineModeration
                      .delete(widget.data.id);

                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
          child: const Text('DELETE MAGAZINE'),
        ),
      ],
    );
  }
}
