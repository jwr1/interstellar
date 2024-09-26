import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/actions.dart';
import 'package:interstellar/src/widgets/settings_header.dart';

import 'settings_controller.dart';

class ActionSettings extends StatelessWidget {
  const ActionSettings({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final isLemmy = controller.serverSoftware == ServerSoftware.lemmy;

    final currentDefaultFeedMode =
        feedTypeSelect(context).getOption(controller.defaultFeedType);
    final currentDefaultFeedFilter =
        feedFilterSelect(context).getOption(controller.defaultFeedFilter);
    final currentDefaultThreadsFeedSort =
        feedSortSelect(context).getOption(controller.defaultThreadsFeedSort);
    final currentDefaultMicroblogFeedSort =
        feedSortSelect(context).getOption(controller.defaultMicroblogFeedSort);
    final currentDefaultExploreFeedSort =
        feedSortSelect(context).getOption(controller.defaultExploreFeedSort);
    final currentDefaultCommentSort =
        commentSortSelect.getOption(controller.defaultCommentSort);

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings_actionsAndDefaults),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsHeader(l(context).settings_feedActions),
          ActionSettingsItem(
            metadata: feedActionExpandFab,
            location: controller.feedActionExpandFab,
            setLocation: controller.updateFeedActionExpandFab,
          ),
          ActionSettingsItem(
            metadata: feedActionBackToTop,
            location: controller.feedActionBackToTop,
            setLocation: controller.updateFeedActionBackToTop,
          ),
          ActionSettingsItem(
            metadata: feedActionCreatePost,
            location: controller.feedActionCreatePost,
            setLocation: controller.updateFeedActionCreatePost,
          ),
          ActionSettingsItem(
            metadata: feedActionRefresh,
            location: controller.feedActionRefresh,
            setLocation: controller.updateFeedActionRefresh,
          ),
          ActionSettingsWithTabsItem(
            metadata: feedActionSetFilter,
            location: controller.feedActionSetFilter,
            setLocation: controller.updateFeedActionSetFilter,
          ),
          ActionSettingsItem(
            metadata: feedActionSetSort,
            location: controller.feedActionSetSort,
            setLocation: controller.updateFeedActionSetSort,
          ),
          ActionSettingsWithTabsItem(
            metadata: feedActionSetType,
            location: controller.feedActionSetType,
            setLocation: controller.updateFeedActionSetType,
          ),
          SettingsHeader(l(context).settings_defaults),
          ListTile(
            title: Text(l(context).settings_feedType),
            leading: const Icon(Icons.tab),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultFeedType(
                await feedTypeSelect(context).askSelection(
                  context,
                  currentDefaultFeedMode.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultFeedMode.icon),
                const SizedBox(width: 4),
                Text(currentDefaultFeedMode.title),
              ],
            ),
          ),
          ListTile(
            title: Text(l(context).settings_feedFilter),
            leading: const Icon(Icons.filter_alt),
            onTap: () async {
              controller.updateDefaultFeedFilter(
                await feedFilterSelect(context).askSelection(
                  context,
                  currentDefaultFeedFilter.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultFeedFilter.icon),
                const SizedBox(width: 4),
                Text(currentDefaultFeedFilter.title),
              ],
            ),
          ),
          ListTile(
            title: Text(l(context).settings_threadsFeedSort),
            leading: const Icon(Icons.sort),
            onTap: () async {
              controller.updateDefaultThreadsFeedSort(
                await feedSortSelect(context).askSelection(
                  context,
                  currentDefaultThreadsFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultThreadsFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultThreadsFeedSort.title),
              ],
            ),
          ),
          ListTile(
            title: Text(l(context).settings_microblogFeedSort),
            leading: const Icon(Icons.sort),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultMicroblogFeedSort(
                await feedSortSelect(context).askSelection(
                  context,
                  currentDefaultMicroblogFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultMicroblogFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultMicroblogFeedSort.title),
              ],
            ),
          ),
          ListTile(
            title: Text(l(context).settings_exploreFeedSort),
            leading: const Icon(Icons.explore),
            onTap: () async {
              controller.updateDefaultExploreFeedSort(
                await feedSortSelect(context).askSelection(
                  context,
                  currentDefaultExploreFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultExploreFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultExploreFeedSort.title),
              ],
            ),
          ),
          ListTile(
            title: Text(l(context).settings_commentSort),
            leading: const Icon(Icons.comment),
            onTap: () async {
              controller.updateDefaultCommentSort(
                await commentSortSelect.askSelection(
                  context,
                  currentDefaultCommentSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultCommentSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultCommentSort.title),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionSettingsItem extends StatelessWidget {
  const ActionSettingsItem({
    super.key,
    required this.metadata,
    required this.location,
    required this.setLocation,
  });

  final ActionItem metadata;
  final ActionLocation location;
  final Future<void> Function(ActionLocation? newLocation) setLocation;

  @override
  Widget build(BuildContext context) {
    final locationOption = actionLocationSelect.getOption(location);

    return ListTile(
      title: Text(metadata.name),
      leading: Icon(metadata.icon),
      onTap: () async {
        setLocation(
          await actionLocationSelect.askSelection(
            context,
            location,
          ),
        );
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(locationOption.icon),
          const SizedBox(width: 4),
          Text(locationOption.title),
        ],
      ),
    );
  }
}

class ActionSettingsWithTabsItem extends StatelessWidget {
  const ActionSettingsWithTabsItem({
    super.key,
    required this.metadata,
    required this.location,
    required this.setLocation,
  });

  final ActionItem metadata;
  final ActionLocationWithTabs location;
  final Future<void> Function(ActionLocationWithTabs? newLocation) setLocation;

  @override
  Widget build(BuildContext context) {
    final locationOption = actionLocationWithTabsSelect.getOption(location);

    return ListTile(
      title: Text(metadata.name),
      leading: Icon(metadata.icon),
      onTap: () async {
        setLocation(
          await actionLocationWithTabsSelect.askSelection(
            context,
            location,
          ),
        );
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(locationOption.icon),
          const SizedBox(width: 4),
          Text(locationOption.title),
        ],
      ),
    );
  }
}
