import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/models/message.dart';
import 'package:interstellar/src/screens/explore/user_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/display_name.dart';
import 'package:interstellar/src/widgets/error_page.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:interstellar/src/widgets/loading_template.dart';
import 'package:interstellar/src/widgets/markdown/drafts_controller.dart';
import 'package:interstellar/src/widgets/markdown/markdown.dart';
import 'package:interstellar/src/widgets/markdown/markdown_editor.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({
    required this.threadId,
    this.initData,
    this.onUpdate,
    super.key,
  });

  final int threadId;
  final MessageThreadModel? initData;
  final void Function(MessageThreadModel)? onUpdate;

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  MessageThreadModel? _data;
  final TextEditingController _controller = TextEditingController();

  final PagingController<String, MessageItemModel> _pagingController =
      PagingController(firstPageKey: '');

  @override
  void initState() {
    super.initState();

    _data = widget.initData;
    if (_data != null) {
      _pagingController.appendPage(_data!.messages, '');
    }

    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      final newPage = await context
          .read<AppController>()
          .api
          .messages
          .getThreadWithMessages(
            threadId: widget.threadId,
            page: nullIfEmpty(pageKey),
          );

      // Check BuildContext
      if (!mounted) return;

      if (_data == null) {
        setState(() {
          _data = newPage;
        });
      }

      // Prevent duplicates
      final currentItemIds = _pagingController.itemList?.map((e) => e.id) ?? [];
      final newItems = newPage.messages
          .where((e) => !currentItemIds.contains(e.id))
          .toList();

      _pagingController.appendPage(newItems, newPage.nextPage);
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUsername =
        context.watch<AppController>().selectedAccount.split('@').first;

    final messageUser = _data?.participants.firstWhere(
      (user) => user.name != myUsername,
      orElse: () => _data!.participants.first,
    );

    final messageDraftController = context.watch<DraftsController>().auto(
        'message:${context.watch<AppController>().instanceHost}:${messageUser?.name}');

    return Scaffold(
      appBar: AppBar(title: Text(messageUser?.name ?? '')),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: CustomScrollView(
          reverse: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(children: [
                  const SizedBox(height: 8),
                  MarkdownEditor(
                    _controller,
                    originInstance: null,
                    draftController: messageDraftController,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LoadingFilledButton(
                        onPressed: () async {
                          final newThread = await context
                              .read<AppController>()
                              .api
                              .messages
                              .postThreadReply(
                                widget.threadId,
                                _controller.text,
                              );

                          await messageDraftController.discard();

                          _controller.text = '';

                          setState(() {
                            _data = newThread;

                            var newList = _pagingController.itemList;
                            newList?.insert(0, newThread.messages.first);
                            setState(() {
                              _pagingController.itemList = newList;
                            });
                          });

                          if (widget.onUpdate != null) {
                            widget.onUpdate!(newThread);
                          }
                        },
                        label: Text(l(context).send),
                        icon: const Icon(Symbols.send_rounded),
                      ),
                    ],
                  )
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: PagedSliverList(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<MessageItemModel>(
                  firstPageErrorIndicatorBuilder: (context) =>
                      FirstPageErrorIndicator(
                    error: _pagingController.error,
                    onTryAgain: _pagingController.retryLastFailedRequest,
                  ),
                  newPageErrorIndicatorBuilder: (context) =>
                      NewPageErrorIndicator(
                    error: _pagingController.error,
                    onTryAgain: _pagingController.retryLastFailedRequest,
                  ),
                  itemBuilder: (context, item, index) {
                    final messages = _pagingController.itemList!;

                    final nextMessage = index - 1 < 0
                        ? null
                        : messages.elementAtOrNull(index - 1);
                    final currMessage = messages[index];
                    final prevMessage = index + 1 >= messages.length
                        ? null
                        : messages.elementAt(index + 1);

                    final isMyUser = currMessage.sender.name == myUsername;

                    final showDate = prevMessage == null ||
                        !DateUtils.isSameDay(
                            currMessage.createdAt, prevMessage.createdAt);
                    final showTime = prevMessage == null ||
                        currMessage.createdAt
                                .difference(prevMessage.createdAt)
                                .inMinutes >
                            15;

                    final showName = showTime ||
                        currMessage.sender.name != prevMessage.sender.name;

                    const defaultRadius = Radius.circular(20);
                    const connectedRadius = Radius.circular(4);

                    final topRadius =
                        showName ? defaultRadius : connectedRadius;
                    final bottomRadius = nextMessage == null ||
                            currMessage.sender.name !=
                                nextMessage.sender.name ||
                            nextMessage.createdAt
                                    .difference(currMessage.createdAt)
                                    .inMinutes >
                                15
                        ? defaultRadius
                        : connectedRadius;

                    return LayoutBuilder(builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: isMyUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(DateUtils.isSameDay(
                                            currMessage.createdAt,
                                            DateTime.now())
                                        ? 'Today'
                                        : dateOnlyFormat(
                                            currMessage.createdAt)),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                            ),
                          if (showTime || showName)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: reverseList([
                                  const Spacer(),
                                  if (showTime)
                                    Text(
                                      timeOnlyFormat(currMessage.createdAt),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w300),
                                    ),
                                  if (showName)
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: isMyUser
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          DisplayName(
                                            currMessage.sender.name,
                                            icon: currMessage.sender.avatar,
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserScreen(
                                                        currMessage.sender.id),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ], !isMyUser),
                              ),
                            ),
                          const SizedBox(height: 4),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: max(constraints.maxWidth * (2 / 3),
                                    min(constraints.maxWidth - 32, 600))),
                            child: Card(
                              color: isMyUser
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: isMyUser ? defaultRadius : topRadius,
                                  topRight:
                                      isMyUser ? topRadius : defaultRadius,
                                  bottomLeft:
                                      isMyUser ? defaultRadius : bottomRadius,
                                  bottomRight:
                                      isMyUser ? bottomRadius : defaultRadius,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Markdown(
                                  currMessage.body,
                                  context.watch<AppController>().instanceHost,
                                  themeData: Theme.of(context).copyWith(
                                    textTheme: isMyUser
                                        ? Theme.of(context).primaryTextTheme
                                        : Theme.of(context).textTheme,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
