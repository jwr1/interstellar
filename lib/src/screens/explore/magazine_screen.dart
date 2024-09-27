import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/explore/magazine_mod_panel.dart';
import 'package:interstellar/src/screens/explore/magazine_owner_panel.dart';
import 'package:interstellar/src/screens/explore/user_item.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/markdown/markdown.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:interstellar/src/widgets/star_button.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
import 'package:provider/provider.dart';

class MagazineScreen extends StatefulWidget {
  final int magazineId;
  final DetailedMagazineModel? initData;
  final void Function(DetailedMagazineModel)? onUpdate;

  const MagazineScreen(this.magazineId,
      {super.key, this.initData, this.onUpdate});

  @override
  State<MagazineScreen> createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  DetailedMagazineModel? _data;

  @override
  void initState() {
    super.initState();

    _data = widget.initData;

    if (_data == null) {
      context
          .read<SettingsController>()
          .api
          .magazines
          .get(widget.magazineId)
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalName = _data == null
        ? null
        : _data!.name.contains('@')
            ? '!${_data!.name}'
            : '!${_data!.name}@${context.watch<SettingsController>().instanceHost}';

    final loggedInUser =
        context.watch<SettingsController>().selectedAccount.split('@').first;

    final isModerator = _data == null
        ? false
        : _data!.moderators.any((mod) => mod.name == loggedInUser);

    return FeedScreen(
      source: FeedSource.magazine,
      sourceId: widget.magazineId,
      title: _data?.name ?? '',
      createPostMagazine: _data,
      details: _data == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(builder: (context, constraints) {
                final actions = [
                  SubscriptionButton(
                    subsCount: _data!.subscriptionsCount,
                    isSubed: _data!.isUserSubscribed == true,
                    onPress: whenLoggedIn(context, () async {
                      var newValue = await context
                          .read<SettingsController>()
                          .api
                          .magazines
                          .subscribe(_data!.id, !_data!.isUserSubscribed!);

                      setState(() {
                        _data = newValue;
                      });
                      if (widget.onUpdate != null) {
                        widget.onUpdate!(newValue);
                      }
                    }),
                  ),
                  StarButton(globalName!),
                  if (whenLoggedIn(context, true) == true)
                    LoadingIconButton(
                      onPressed: () async {
                        final newValue = await context
                            .read<SettingsController>()
                            .api
                            .magazines
                            .block(
                              _data!.id,
                              !_data!.isBlockedByUser!,
                            );

                        setState(() {
                          _data = newValue;
                        });
                        if (widget.onUpdate != null) {
                          widget.onUpdate!(newValue);
                        }
                      },
                      icon: const Icon(Icons.block),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                            _data!.isBlockedByUser == true
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).disabledColor),
                      ),
                    ),
                  MenuAnchor(
                    builder: (BuildContext context, MenuController controller,
                        Widget? child) {
                      return IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => openWebpagePrimary(
                            context,
                            Uri.https(
                              context.read<SettingsController>().instanceHost,
                              context
                                          .read<SettingsController>()
                                          .serverSoftware ==
                                      ServerSoftware.lemmy
                                  ? '/c/${_data!.name}'
                                  : '/m/${_data!.name}',
                            )),
                        child: Text(l(context).openInBrowser),
                      ),
                      MenuItemButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l(context).modsOf(_data!.name)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _data!.moderators
                                  .map((mod) => UserItemSimple(
                                        mod,
                                        isOwner: mod.id == _data!.owner?.id,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        child: Text(l(context).viewMods),
                      ),
                      if (isModerator)
                        MenuItemButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MagazineModPanel(
                                initData: _data!,
                                onUpdate: (newValue) {
                                  setState(() {
                                    _data = newValue;
                                  });
                                  if (widget.onUpdate != null) {
                                    widget.onUpdate!(newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                          child: Text(l(context).modPanel),
                        ),
                      if (_data!.owner != null &&
                          _data!.owner!.name ==
                              context
                                  .watch<SettingsController>()
                                  .selectedAccount
                                  .split('@')
                                  .first)
                        MenuItemButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MagazineOwnerPanel(
                                initData: _data!,
                                onUpdate: (newValue) {
                                  setState(() {
                                    _data = newValue;
                                  });
                                  if (widget.onUpdate != null) {
                                    widget.onUpdate!(newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                          child: Text(l(context).ownerPanel),
                        ),
                    ],
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (_data!.icon != null)
                          Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Avatar(_data!.icon, radius: 32)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _data!.title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (_data!.isPostingRestrictedToMods)
                                    const PostingRestrictedIndicator(),
                                ],
                              ),
                              InkWell(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                        text: _data!.name.contains('@')
                                            ? '!${_data!.name}'
                                            : '!${_data!.name}@${context.read<SettingsController>().instanceHost}'),
                                  );

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l(context).copied),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text(globalName),
                              )
                            ],
                          ),
                        ),
                        if (constraints.maxWidth > 600) ...actions,
                      ],
                    ),
                    if (constraints.maxWidth <= 600)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions,
                      ),
                    if (_data!.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Markdown(
                          _data!.description!,
                          getNameHost(context, _data!.name),
                        ),
                      )
                  ],
                );
              }),
            ),
    );
  }
}

class PostingRestrictedIndicator extends StatelessWidget {
  const PostingRestrictedIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Tooltip(
        message: l(context).postingRestricted,
        triggerMode: TooltipTriggerMode.tap,
        child: const Icon(Icons.lock, size: 16),
      ),
    );
  }
}
