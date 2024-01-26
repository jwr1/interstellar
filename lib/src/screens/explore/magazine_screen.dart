import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/feed_screen.dart';
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
      api_magazines
          .fetchMagazine(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.magazineId,
          )
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeedScreen(
      contentSource: ContentMagazine(widget.magazineId),
      title: Text(_data?.name ?? ''),
      details: _data != null
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (_data!.icon?.storageUrl != null)
                        Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Avatar(_data!.icon!.storageUrl, radius: 32)),
                      Expanded(
                        child: Text(
                          _data!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          softWrap: true,
                        ),
                      ),
                      OutlinedButton(
                        style: ButtonStyle(
                            foregroundColor: _data!.isUserSubscribed == true
                                ? MaterialStatePropertyAll(
                                    Colors.purple.shade400,
                                  )
                                : null),
                        onPressed: whenLoggedIn(context, () async {
                          var newValue = await api_magazines.putSubscribe(
                              context.read<SettingsController>().httpClient,
                              context.read<SettingsController>().instanceHost,
                              _data!.magazineId,
                              !_data!.isUserSubscribed!);

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
                      )
                    ],
                  ),
                  if (_data!.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Markdown(_data!.description!),
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
