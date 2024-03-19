import 'package:flutter/material.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';

enum ActionLocation { hide, appBar, fabTap, fabHold, fabMenu }

enum ActionLocationWithTabs { hide, appBar, fabTap, fabHold, fabMenu, tabs }

class ActionItem {
  final String name;
  final IconData icon;
  final void Function()? callback;
  final ActionLocation? location;

  const ActionItem({
    required this.name,
    required this.icon,
    this.callback,
    this.location,
  });

  ActionItem withProps(ActionLocation location, void Function() callback) =>
      ActionItem(
          name: name, icon: icon, callback: callback, location: location);
}

const feedActionBackToTop = ActionItem(
  name: 'Back To Top',
  icon: Icons.keyboard_double_arrow_up,
);
const feedActionCreatePost = ActionItem(
  name: 'Create Post',
  icon: Icons.create,
);
const feedActionExpandFab = ActionItem(
  name: 'Expand FAB Menu',
  icon: Icons.menu,
);
const feedActionRefresh = ActionItem(
  name: 'Refresh',
  icon: Icons.refresh,
);
const feedActionSetFilter = ActionItem(
  name: 'Set Filter',
  icon: Icons.filter_alt,
);
const feedActionSetSort = ActionItem(
  name: 'Set Sort',
  icon: Icons.sort,
);
const feedActionSetType = ActionItem(
  name: 'Set Type',
  icon: Icons.tab,
);

const SelectionMenu<ActionLocation> actionLocationSelect = SelectionMenu(
  'Set Action Location',
  [
    SelectionMenuItem(
      value: ActionLocation.hide,
      title: 'Hide',
      icon: Icons.visibility_off,
    ),
    SelectionMenuItem(
      value: ActionLocation.appBar,
      title: 'App Bar',
      icon: Icons.web_asset,
    ),
    SelectionMenuItem(
      value: ActionLocation.fabTap,
      title: 'FAB Tap',
      icon: Icons.touch_app,
    ),
    SelectionMenuItem(
      value: ActionLocation.fabHold,
      title: 'FAB Hold',
      icon: Icons.touch_app,
    ),
    SelectionMenuItem(
      value: ActionLocation.fabMenu,
      title: 'FAB Menu',
      icon: Icons.menu,
    ),
  ],
);

const SelectionMenu<ActionLocationWithTabs> actionLocationWithTabsSelect =
    SelectionMenu(
  'Set Action Location',
  [
    SelectionMenuItem(
      value: ActionLocationWithTabs.hide,
      title: 'Hide',
      icon: Icons.visibility_off,
    ),
    SelectionMenuItem(
      value: ActionLocationWithTabs.appBar,
      title: 'App Bar',
      icon: Icons.web_asset,
    ),
    SelectionMenuItem(
      value: ActionLocationWithTabs.fabTap,
      title: 'FAB Tap',
      icon: Icons.touch_app,
    ),
    SelectionMenuItem(
      value: ActionLocationWithTabs.fabHold,
      title: 'FAB Hold',
      icon: Icons.touch_app,
    ),
    SelectionMenuItem(
      value: ActionLocationWithTabs.fabMenu,
      title: 'FAB Menu',
      icon: Icons.menu,
    ),
    SelectionMenuItem(
      value: ActionLocationWithTabs.tabs,
      title: 'Tabs',
      icon: Icons.tab,
    ),
  ],
);
