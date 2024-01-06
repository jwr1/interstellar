import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/api/domains.dart' as api_domains;
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/screens/entries/entries_list.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class DomainScreen extends StatefulWidget {
  final int domainId;
  final DomainModel? data;
  final void Function(DomainModel)? onUpdate;

  const DomainScreen(this.domainId, {super.key, this.data, this.onUpdate});

  @override
  State<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  DomainModel? _data;

  @override
  void initState() {
    super.initState();

    _data = widget.data;

    if (_data == null) {
      api_domains
          .fetchDomain(
            context.read<SettingsController>().httpClient,
            context.read<SettingsController>().instanceHost,
            widget.domainId,
          )
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
                          style: ButtonStyle(
                              foregroundColor: _data!.isUserSubscribed == true
                                  ? MaterialStatePropertyAll(
                                      Colors.purple.shade400)
                                  : null),
                          onPressed: whenLoggedIn(context, () async {
                            var newValue = await api_domains.putSubscribe(
                                context.read<SettingsController>().httpClient,
                                context.read<SettingsController>().instanceHost,
                                _data!.domainId,
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
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
