import 'package:flutter/material.dart';
import 'package:interstellar/src/api/entries.dart' as api_entries;
import 'package:interstellar/src/entries/entry_item.dart';
import 'package:interstellar/src/settings/settings_controller.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({
    super.key,
  });

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  api_entries.EntriesSort sort = api_entries.EntriesSort.hot;

  late Future<api_entries.Entries> entries;

  final PagingController<int, api_entries.EntryItem> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await api_entries.fetchEntries(
          context.read<SettingsController>().instanceHost,
          page: pageKey,
          sort: sort);

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;

      if (isLastPage) {
        _pagingController.appendLastPage(newPage.items);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newPage.items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Browse'),
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      DropdownButton<api_entries.EntriesSort>(
                        value: sort,
                        onChanged: (newSort) {
                          if (newSort != null) {
                            setState(() {
                              sort = newSort;
                              _pagingController.refresh();
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: api_entries.EntriesSort.hot,
                            child: Text('Hot'),
                          ),
                          DropdownMenuItem(
                            value: api_entries.EntriesSort.top,
                            child: Text('Top'),
                          ),
                          DropdownMenuItem(
                            value: api_entries.EntriesSort.newest,
                            child: Text('Newest'),
                          ),
                          DropdownMenuItem(
                            value: api_entries.EntriesSort.active,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: api_entries.EntriesSort.commented,
                            child: Text('Commented'),
                          ),
                          DropdownMenuItem(
                            value: api_entries.EntriesSort.oldest,
                            child: Text('Oldest'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PagedSliverList<int, api_entries.EntryItem>(
                pagingController: _pagingController,
                builderDelegate:
                    PagedChildBuilderDelegate<api_entries.EntryItem>(
                  itemBuilder: (context, item, index) => EntryCard(
                    item: item,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
