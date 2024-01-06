import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/api/magazines.dart' as api_magazines;
import 'package:interstellar/src/models/magazine.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/avatar.dart';
import 'package:provider/provider.dart';

class MagazinesScreen extends StatefulWidget {
  const MagazinesScreen({
    super.key,
  });

  @override
  State<MagazinesScreen> createState() => _MagazinesScreenState();
}

class _MagazinesScreenState extends State<MagazinesScreen> {
  api_magazines.MagazinesSort sort = api_magazines.MagazinesSort.hot;
  String search = "";

  final PagingController<int, DetailedMagazineModel> _pagingController =
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
      final newPage = await api_magazines.fetchMagazines(
          context.read<SettingsController>().httpClient,
          context.read<SettingsController>().instanceHost,
          page: pageKey,
          sort: sort,
          search: search.isEmpty ? null : search);

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
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  DropdownButton<api_magazines.MagazinesSort>(
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
                        value: api_magazines.MagazinesSort.hot,
                        child: Text('Hot'),
                      ),
                      DropdownMenuItem(
                        value: api_magazines.MagazinesSort.active,
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: api_magazines.MagazinesSort.newest,
                        child: Text('Newest'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
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
                          border: OutlineInputBorder(), label: Text('Search')),
                    ),
                  )
                ],
              ),
            ),
          ),
          PagedSliverList<int, DetailedMagazineModel>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<DetailedMagazineModel>(
              itemBuilder: (context, item, index) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MagazineScreen(
                        item.magazineId,
                        data: item,
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
                  padding: const EdgeInsets.all(12.0),
                  child: Row(children: [
                    if (item.icon?.storageUrl != null)
                      Avatar(item.icon!.storageUrl, radius: 16),
                    Container(
                        width: 8 + (item.icon?.storageUrl != null ? 0 : 32)),
                    Expanded(
                        child:
                            Text(item.name, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.feed),
                    Container(
                      width: 4,
                    ),
                    Text(intFormat(item.entryCount)),
                    const SizedBox(width: 12),
                    const Icon(Icons.comment),
                    Container(
                      width: 4,
                    ),
                    Text(intFormat(item.entryCommentCount)),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: ButtonStyle(
                          foregroundColor: item.isUserSubscribed == true
                              ? MaterialStatePropertyAll(Colors.purple.shade400)
                              : null),
                      onPressed: whenLoggedIn(context, () async {
                        var newValue = await api_magazines.putSubscribe(
                            context.read<SettingsController>().httpClient,
                            context.read<SettingsController>().instanceHost,
                            item.magazineId,
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
