import 'package:flutter/material.dart';
import 'package:interstellar/src/api/content_sources.dart';
import 'package:interstellar/src/screens/entries/entries_list.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({
    super.key,
  });

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
      ),
      body: const EntriesListView(
        contentSource: ContentAll(),
      ),
    );
  }
}
