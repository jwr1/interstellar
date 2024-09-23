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
        feedTypeSelect.getOption(controller.defaultFeedType);
    final currentDefaultFeedFilter =
        feedFilterSelect.getOption(controller.defaultFeedFilter);
    final currentDefaultThreadsFeedSort =
        feedSortSelect.getOption(controller.defaultThreadsFeedSort);
    final currentDefaultMicroblogFeedSort =
        feedSortSelect.getOption(controller.defaultMicroblogFeedSort);
    final currentDefaultExploreFeedSort =
        feedSortSelect.getOption(controller.defaultExploreFeedSort);
    final currentDefaultCommentSort =
        commentSortSelect.getOption(controller.defaultCommentSort);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n(context).actionsAndDefaults),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SettingsHeader('Feed Actions'),
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
          const SettingsHeader('Defaults'),
          ListTile(
            title: const Text('Feed Type'),
            leading: const Icon(Icons.tab),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultFeedType(
                await feedTypeSelect.askSelection(
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
            title: const Text('Feed Filter'),
            leading: const Icon(Icons.filter_alt),
            onTap: () async {
              controller.updateDefaultFeedFilter(
                await feedFilterSelect.askSelection(
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
            title: const Text('Threads Feed Sort'),
            leading: const Icon(Icons.sort),
            onTap: () async {
              controller.updateDefaultThreadsFeedSort(
                await feedSortSelect.askSelection(
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
            title: const Text('Microblog Feed Sort'),
            leading: const Icon(Icons.sort),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultMicroblogFeedSort(
                await feedSortSelect.askSelection(
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
            title: const Text('Explore Feed Sort'),
            leading: const Icon(Icons.explore),
            onTap: () async {
              controller.updateDefaultExploreFeedSort(
                await feedSortSelect.askSelection(
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
            title: const Text('Comment Sort'),
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
