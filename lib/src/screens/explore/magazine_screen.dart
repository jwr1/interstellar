import 'package:flutter/material.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/floating_menu.dart';
import 'package:interstellar/src/widgets/markdown.dart';
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
          .kbinAPI
          .magazines
          .get(widget.magazineId)
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeedScreen(
      source: FeedSourceMagazine(widget.magazineId),
      title: _data?.name ?? '',
      details: _data != null
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (_data!.icon != null)
                        Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Avatar(_data!.icon, radius: 32)),
                      Expanded(
                        child: Text(
                          _data!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          softWrap: true,
                        ),
                      ),
                      OutlinedButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStatePropertyAll(
                              _data!.isUserSubscribed == true
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null),
                        ),
                        onPressed: whenLoggedIn(context, () async {
                          var newValue = await context
                              .read<SettingsController>()
                              .kbinAPI
                              .magazines
                              .putSubscribe(
                                  _data!.id, !_data!.isUserSubscribed!);

                          setState(() {
                            _data = newValue;
                          });
                          if (widget.onUpdate != null) {
                            widget.onUpdate!(newValue);
                          }
                        }),
                        child: Row(
                          children: [
                            const Icon(Icons.group),
                            Text(' ${intFormat(_data!.subscriptionsCount)}'),
                          ],
                        ),
                      ),
                      if (whenLoggedIn(context, true) == true)
                        IconButton(
                          onPressed: () async {
                            final newValue = await context
                                .read<SettingsController>()
                                .kbinAPI
                                .magazines
                                .putBlock(
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
                            foregroundColor: MaterialStatePropertyAll(
                                _data!.isBlockedByUser == true
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).disabledColor),
                          ),
                        ),
                    ],
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
              ),
            )
          : null,
      floatingActionButton: whenLoggedIn(
        context,
        FloatingMenu(
          magazineId: widget.magazineId,
          magazineName: _data?.name,
        ),
      ),
    );
  }
}
