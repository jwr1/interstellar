import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class FeedDefaultSettingsScreen extends StatelessWidget {
  const FeedDefaultSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings_feedDefaults),
      ),
      body: ListView(
        children: [
          _FeedDefaultListTile(
            title: l(context).settings_feedDefaults_type,
            icon: Symbols.tab,
            selectionMenu: feedTypeSelect(context),
            value: ac.profile.feedDefaultType,
            oldValue: ac.selectedProfileValue.feedDefaultType,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue.copyWith(feedDefaultType: newValue),
            ),
          ),
          _FeedDefaultListTile(
            title: l(context).settings_feedDefaults_filter,
            icon: Symbols.filter_list_rounded,
            selectionMenu: feedFilterSelect(context),
            value: ac.profile.feedDefaultFilter,
            oldValue: ac.selectedProfileValue.feedDefaultFilter,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue.copyWith(feedDefaultFilter: newValue),
            ),
          ),
          _FeedDefaultListTile(
            title: l(context).settings_feedDefaults_threadsSort,
            icon: Symbols.newsmode_rounded,
            selectionMenu: feedSortSelect(context),
            value: ac.profile.feedDefaultThreadsSort,
            oldValue: ac.selectedProfileValue.feedDefaultThreadsSort,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .copyWith(feedDefaultThreadsSort: newValue),
            ),
          ),
          _FeedDefaultListTile(
            title: l(context).settings_feedDefaults_microblogSort,
            icon: Symbols.article_rounded,
            selectionMenu: feedSortSelect(context),
            value: ac.profile.feedDefaultMicroblogSort,
            oldValue: ac.selectedProfileValue.feedDefaultMicroblogSort,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .copyWith(feedDefaultMicroblogSort: newValue),
            ),
          ),
          _FeedDefaultListTile(
            title: l(context).settings_feedDefaults_exploreSort,
            icon: Symbols.explore_rounded,
            selectionMenu: feedSortSelect(context),
            value: ac.profile.feedDefaultExploreSort,
            oldValue: ac.selectedProfileValue.feedDefaultExploreSort,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .copyWith(feedDefaultExploreSort: newValue),
            ),
          ),
          _FeedDefaultListTile(
            title: l(context).settings_feedDefaults_commentSort,
            icon: Symbols.comment_rounded,
            selectionMenu: commentSortSelect(context),
            value: ac.profile.feedDefaultCommentSort,
            oldValue: ac.selectedProfileValue.feedDefaultCommentSort,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .copyWith(feedDefaultCommentSort: newValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedDefaultListTile<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final SelectionMenu<T> selectionMenu;
  final T value;
  final T? oldValue;
  final void Function(T newValue) onChange;

  const _FeedDefaultListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.selectionMenu,
    required this.value,
    required this.oldValue,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final curOption = selectionMenu.getOption(value);

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(curOption.icon, size: 20),
          const SizedBox(width: 4),
          Text(curOption.title),
          const Icon(Symbols.arrow_drop_down_rounded),
        ],
      ),
      onTap: () async {
        final newValue = await selectionMenu.askSelection(context, oldValue);

        if (newValue == null) return;

        onChange(newValue);
      },
    );
  }
}
