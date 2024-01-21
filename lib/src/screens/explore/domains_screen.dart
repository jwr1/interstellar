import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/domains.dart' as api_domains;
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:provider/provider.dart';

class DomainsScreen extends StatefulWidget {
  const DomainsScreen({
    super.key,
  });

  @override
  State<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends State<DomainsScreen> {
  api_domains.DomainsFilter filter = api_domains.DomainsFilter.all;
  String search = "";

  final PagingController<int, DomainModel> _pagingController =
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
      final newPage = await api_domains.fetchDomains(
        context.read<SettingsController>().httpClient,
        context.read<SettingsController>().instanceHost,
        page: pageKey,
        filter: filter,
        search: search.isEmpty ? null : search,
      );

      // Check BuildContext
      if (!mounted) return;

      final isLastPage =
          newPage.pagination.currentPage == newPage.pagination.maxPage;
      // Prevent duplicates
      final currentItemIds =
          _pagingController.itemList?.map((e) => e.domainId) ?? [];
      final newItems = newPage.items
          .where((e) => !currentItemIds.contains(e.domainId))
          .toList();

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ...whenLoggedIn(context, [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: DropdownButton<api_domains.DomainsFilter>(
                            value: filter,
                            onChanged: (newFilter) {
                              if (newFilter != null) {
                                setState(() {
                                  filter = newFilter;
                                  _pagingController.refresh();
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: api_domains.DomainsFilter.all,
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: api_domains.DomainsFilter.subscribed,
                                child: Text('Subscribed'),
                              ),
                              DropdownMenuItem(
                                value: api_domains.DomainsFilter.blocked,
                                child: Text('Blocked'),
                              ),
                            ],
                          ),
                        )
                      ]) ??
                      [],
                  if (filter == api_domains.DomainsFilter.all)
                    SizedBox(
                      width: 128,
                      child: TextFormField(
                        initialValue: search,
                        onChanged: (newSearch) {
                          setState(() {
                            search = newSearch;
                            _pagingController.refresh();
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Search')),
                      ),
                    )
                ],
              ),
            ),
          ),
          PagedSliverList<int, DomainModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DomainModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DomainScreen(
                        item.domainId,
                        initData: item,
                        onUpdate: (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Expanded(
                        child:
                            Text(item.name, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.feed),
                    Container(
                      width: 4,
                    ),
                    Text(intFormat(item.entryCount)),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: ButtonStyle(
                          foregroundColor: item.isUserSubscribed == true
                              ? MaterialStatePropertyAll(Colors.purple.shade400)
                              : null),
                      onPressed: whenLoggedIn(context, () async {
                        var newValue = await api_domains.putSubscribe(
                            context.read<SettingsController>().httpClient,
                            context.read<SettingsController>().instanceHost,
                            item.domainId,
                            !item.isUserSubscribed!);
                        var newList = _pagingController.itemList;
                        newList![index] = newValue;
                        setState(() {
                          _pagingController.itemList = newList;
                        });
                      }),
                      child: Row(
                        children: [
                          const Icon(Icons.group),
                          Text(' ${intFormat(item.subscriptionsCount)}'),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
