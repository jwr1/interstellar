import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:interstellar/src/widgets/markdown.dart';
import 'package:provider/provider.dart';

class MagazineScreen extends StatefulWidget {
  final int magazineId;
  final api_magazines.DetailedMagazine? data;

  const MagazineScreen(this.magazineId, {super.key, this.data});

  @override
  State<MagazineScreen> createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  api_magazines.DetailedMagazine? _data;

  @override
  void initState() {
    super.initState();

    _data = widget.data;

    if (_data == null) {
      api_magazines
          .fetchMagazine(context.read<SettingsController>().instanceHost,
              widget.magazineId)
          .then((value) => setState(() {
                _data = value;
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_data?.name ?? '')),
      body: EntriesListView(
        contentSource: ContentMagazine(widget.magazineId),
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
                              child:
                                  Avatar(_data!.icon!.storageUrl, radius: 32)),
                        Expanded(
                          child: Text(
                            _data!.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            softWrap: true,
                          ),
                        ),
                        OutlinedButton(
                            onPressed: () {},
                            child: Row(
                              children: [
                                const Icon(Icons.group),
                                Text(
                                    ' ${intFormat(_data!.subscriptionsCount)}'),
                              ],
                            ))
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
      ),
    );
  }
}
