import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      icon: Symbols.keyboard_double_arrow_up_rounded,
    );
ActionItem feedActionCreatePost(BuildContext context) => ActionItem(
      name: l(context).action_createPost,
      icon: Symbols.create_rounded,
    );
ActionItem feedActionExpandFab(BuildContext context) => ActionItem(
      name: l(context).action_expandFABMenu,
      icon: Symbols.menu_rounded,
    );
ActionItem feedActionRefresh(BuildContext context) => ActionItem(
      name: l(context).action_refresh,
      icon: Symbols.refresh_rounded,
    );
ActionItem feedActionSetFilter(BuildContext context) => ActionItem(
      name: l(context).action_setFilter,
      icon: Symbols.filter_alt_rounded,
    );
ActionItem feedActionSetSort(BuildContext context) => ActionItem(
      name: l(context).action_setSort,
      icon: Symbols.sort_rounded,
    );
ActionItem feedActionSetType(BuildContext context) => ActionItem(
      name: l(context).action_setType,
      icon: Symbols.tab_rounded,
    );

SelectionMenu<ActionLocation> actionLocationSelect(BuildContext context) =>
    SelectionMenu(
      l(context).action_setLocation,
      [
        SelectionMenuItem(
          value: ActionLocation.hide,
          title: l(context).action_hide,
          icon: Symbols.visibility_off_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocation.appBar,
          title: l(context).action_appBar,
          icon: Symbols.web_asset_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocation.fabTap,
          title: l(context).action_fabTap,
          icon: Symbols.touch_app_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocation.fabHold,
          title: l(context).action_fabHold,
          icon: Symbols.touch_app_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocation.fabMenu,
          title: l(context).action_fabMenu,
          icon: Symbols.menu_rounded,
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
          icon: Symbols.visibility_off_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.appBar,
          title: l(context).action_appBar,
          icon: Symbols.web_asset_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.fabTap,
          title: l(context).action_fabTap,
          icon: Symbols.touch_app_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.fabHold,
          title: l(context).action_fabHold,
          icon: Symbols.touch_app_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.fabMenu,
          title: l(context).action_fabMenu,
          icon: Symbols.menu_rounded,
        ),
        SelectionMenuItem(
          value: ActionLocationWithTabs.tabs,
          title: l(context).action_tabs,
          icon: Symbols.tab_rounded,
        ),
      ],
    );
