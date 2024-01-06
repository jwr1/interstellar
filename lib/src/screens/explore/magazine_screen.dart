import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/feed_screen.dart';
import 'package:interstellar/src/screens/posts/posts_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class MagazineScreen extends StatefulWidget {
  final int magazineId;
  final DetailedMagazineModel? data;
  final void Function(DetailedMagazineModel)? onUpdate;

  const MagazineScreen(this.magazineId, {super.key, this.data, this.onUpdate});

  @override
  State<MagazineScreen> createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  DetailedMagazineModel? _data;
  FeedMode _feedMode = FeedMode.entries;

  @override
  void initState() {
    super.initState();

    _data = widget.data;

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

  Widget _magazineDetails() {
    return Padding(
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
                        ? MaterialStatePropertyAll(Colors.purple.shade400)
                        : null),
                onPressed: whenLoggedIn(context, () async {
                  var newValue = await api_magazines.putSubscribe(
                      context.read<SettingsController>().httpClient,
                      context.read<SettingsController>().instanceHost,
                      _data!.magazineId,
                      !_data!.isUserSubscribed!);

                  if (widget.onUpdate != null) {
                    widget.onUpdate!(newValue);
                  }
                  setState(() {
                    _data = newValue;
                  });
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_data?.name ?? ''),
          actions: [
            SegmentedButton(
              segments: const [
                ButtonSegment(
                  value: FeedMode.entries,
                  label: Text("Threads"),
                ),
                ButtonSegment(
                  value: FeedMode.posts,
                  label: Text("Posts"),
                ),
              ],
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
              ),
              selected: <FeedMode>{_feedMode},
              onSelectionChanged: (Set<FeedMode> newSelection) {
                setState(() {
                  _feedMode = newSelection.first;
                });
              },
            ),
          ],
        ),
        body: switch (_feedMode) {
          FeedMode.entries => EntriesListView(
              contentSource: ContentMagazine(widget.magazineId),
              details: _data != null ? _magazineDetails() : null,
            ),
          FeedMode.posts => PostsListView(
              contentSource: ContentMagazine(widget.magazineId),
              details: _data != null ? _magazineDetails() : null,
            ),
        });
  }
}
