import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/domains.dart';
import 'package:interstellar/src/models/domain.dart';
import 'package:interstellar/src/screens/explore/domain_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/subscription_button.dart';
import 'package:provider/provider.dart';

class DomainsScreen extends StatefulWidget {
  const DomainsScreen({
    super.key,
  });

  @override
  State<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends State<DomainsScreen> {
  KbinAPIDomainsFilter filter = KbinAPIDomainsFilter.all;
  String search = "";

  final PagingController<String, DomainModel> _pagingController =
      PagingController(firstPageKey: '');

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage = await context.read<SettingsController>().api.domains.list(
            page: nullIfEmpty(pageKey),
            filter: filter,
            search: nullIfEmpty(search),
          );

      // Check BuildContext
      if (!mounted) return;

      // Prevent duplicates
      final currentItemIds = _pagingController.itemList?.map((e) => e.id) ?? [];
      final newItems =
          newPage.items.where((e) => !currentItemIds.contains(e.id)).toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
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
                          child: DropdownButton<KbinAPIDomainsFilter>(
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
                                value: KbinAPIDomainsFilter.all,
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: KbinAPIDomainsFilter.subscribed,
                                child: Text('Subscribed'),
                              ),
                              DropdownMenuItem(
                                value: KbinAPIDomainsFilter.blocked,
                                child: Text('Blocked'),
                              ),
                            ],
                          ),
                        )
                      ]) ??
                      [],
                  if (filter == KbinAPIDomainsFilter.all)
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
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DomainModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DomainScreen(
                        item.id,
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
                    SubscriptionButton(
                      subsCount: item.subscriptionsCount,
                      isSubed: item.isUserSubscribed == true,
                      onPress: whenLoggedIn(context, () async {
                        var newValue = await context
                            .read<SettingsController>()
                            .api
                            .domains
                            .putSubscribe(item.id, !item.isUserSubscribed!);
                        var newList = _pagingController.itemList;
                        newList![index] = newValue;
                        setState(() {
                          _pagingController.itemList = newList;
                        });
                      }),
                    ),
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
