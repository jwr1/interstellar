import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/domains.dart' as api_domains;
import 'package:interstellar/src/api/shared.dart' as api_shared;
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class DomainScreen extends StatefulWidget {
  final int domainId;
  final api_shared.Domain? data;

  const DomainScreen(this.domainId, {super.key, this.data});

  @override
  State<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  api_shared.Domain? _data;

  @override
  void initState() {
    super.initState();

    _data = widget.data;

    if (_data == null) {
      api_domains
          .fetchDomain(
              context.read<SettingsController>().instanceHost, widget.domainId)
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
        contentSource: ContentDomain(widget.domainId),
        details: _data != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _data!.name,
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
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
