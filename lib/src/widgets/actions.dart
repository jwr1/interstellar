import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';
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

ActionItem feedActionBackToTop(BuildContext context) => ActionItem(
      name: l(context).action_backToTop,
      icon: Icons.keyboard_double_arrow_up,
    );
ActionItem feedActionCreatePost(BuildContext context) => ActionItem(
      name: l(context).action_createPost,
      icon: Icons.create,
    );
ActionItem feedActionExpandFab(BuildContext context) => ActionItem(
      name: l(context).action_expandFABMenu,
      icon: Icons.menu,
    );
ActionItem feedActionRefresh(BuildContext context) => ActionItem(
      name: l(context).action_refresh,
      icon: Icons.refresh,
    );
ActionItem feedActionSetFilter(BuildContext context) => ActionItem(
      name: l(context).action_setFilter,
      icon: Icons.filter_alt,
    );
ActionItem feedActionSetSort(BuildContext context) => ActionItem(
      name: l(context).action_setSort,
      icon: Icons.sort,
    );
ActionItem feedActionSetType(BuildContext context) => ActionItem(
      name: l(context).action_setType,
      icon: Icons.tab,
    );

SelectionMenu<ActionLocation> actionLocationSelect(BuildContext context) =>
    SelectionMenu(
      l(context).action_setLocation,
      [
        SelectionMenuItem(
          value: ActionLocation.hide,
          title: l(context).action_hide,
          icon: Icons.visibility_off,
        ),
        SelectionMenuItem(
          value: ActionLocation.appBar,
          title: l(context).action_appBar,
          icon: Icons.web_asset,
        ),
        SelectionMenuItem(
          value: ActionLocation.fabTap,
          title: l(context).action_fabTap,
          icon: Icons.touch_app,
        ),
        SelectionMenuItem(
          value: ActionLocation.fabHold,
          title: l(context).action_fabHold,
          icon: Icons.touch_app,
        ),
        SelectionMenuItem(
          value: ActionLocation.fabMenu,
          title: l(context).action_fabMenu,
          icon: Icons.menu,
        ),
      ],
    );

SelectionMenu<ActionLocationWithTabs> actionLocationWithTabsSelect(
        BuildContext context) =>
    SelectionMenu(
      l(context).action_setLocation,
      [
        SelectionMenuItem(
          value: ActionLocationWithTabs.hide,
          title: l(context).action_hide,
          icon: Icons.visibility_off,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.appBar,
          title: l(context).action_appBar,
          icon: Icons.web_asset,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.fabTap,
          title: l(context).action_fabTap,
          icon: Icons.touch_app,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.fabHold,
          title: l(context).action_fabHold,
          icon: Icons.touch_app,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.fabMenu,
          title: l(context).action_fabMenu,
          icon: Icons.menu,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.tabs,
          title: l(context).action_tabs,
          icon: Icons.tab,
        ),
      ],
    );
