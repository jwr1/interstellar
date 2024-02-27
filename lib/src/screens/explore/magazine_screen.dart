import 'package:flutter/material.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/floating_menu.dart';
import 'package:interstellar/src/widgets/markdown.dart';
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
    return FeedScreen(
      source: FeedSource.magazine,
      sourceId: widget.magazineId,
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
                      if (whenLoggedIn(context, true) == true)
                        IconButton(
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
