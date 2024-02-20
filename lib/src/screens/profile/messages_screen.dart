import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/screens/profile/message_item.dart';
import 'package:interstellar/src/screens/profile/message_thread_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final PagingController<String, MessageThreadModel> _pagingController =
      PagingController(firstPageKey: '1');

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage =
          await context.read<SettingsController>().api.messages.list(
                page: int.parse(pageKey),
              );

      // Check BuildContext
      if (!mounted) return;

      // Prevent duplicates
      final currentItemIds =
          _pagingController.itemList?.map((e) => e.threadId) ?? [];
      final newItems = newPage.items
          .where((e) => !currentItemIds.contains(e.threadId))
          .toList();

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
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<MessageThreadModel>(
              itemBuilder: (context, item, index) =>
                  MessageItem(item, (newValue) {
                var newList = _pagingController.itemList;
                newList![index] = newValue;
                setState(() {
                  _pagingController.itemList = newList;
                });
              }, onClick: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MessageThreadScreen(
                        initData: item,
                        onUpdate: (newValue) {
                          var newList = _pagingController.itemList;
                          newList![index] = newValue;
                          setState(() {
                            _pagingController.itemList = newList;
                          });
                        }),
                  ),
                );
              }),
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
