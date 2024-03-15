import 'package:flutter/material.dart';

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
  icon: Icons.compare,
);
