import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/actions.dart';
import 'package:interstellar/src/widgets/list_tile_select.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class FeedActionsSettingsScreen extends StatelessWidget {
  const FeedActionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings_feedActions),
      ),
      body: ListView(
        children: [
          ListTileSelect(
            title: l(context).action_expandFABMenu,
            icon: Symbols.menu_rounded,
            selectionMenu: actionLocationSelect(context),
            value: ac.profile.feedActionExpandFab,
            oldValue: ac.selectedProfileValue.feedActionExpandFab,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionExpandFab: newValue),
            ),
          ),
          ListTileSelect(
            title: l(context).action_backToTop,
            icon: Symbols.keyboard_double_arrow_up_rounded,
            selectionMenu: actionLocationSelect(context),
            value: ac.profile.feedActionBackToTop,
            oldValue: ac.selectedProfileValue.feedActionBackToTop,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionBackToTop: newValue),
            ),
          ),
          ListTileSelect(
            title: l(context).action_createNew,
            icon: Symbols.create_rounded,
            selectionMenu: actionLocationSelect(context),
            value: ac.profile.feedActionCreateNew,
            oldValue: ac.selectedProfileValue.feedActionCreateNew,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionCreateNew: newValue),
            ),
          ),
          ListTileSelect(
            title: l(context).action_refresh,
            icon: Symbols.refresh_rounded,
            selectionMenu: actionLocationSelect(context),
            value: ac.profile.feedActionRefresh,
            oldValue: ac.selectedProfileValue.feedActionRefresh,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionRefresh: newValue),
            ),
          ),
          ListTileSelect(
            title: l(context).action_setFilter,
            icon: Symbols.filter_alt_rounded,
            selectionMenu: actionLocationWithTabsSelect(context),
            value: ac.profile.feedActionSetFilter,
            oldValue: ac.selectedProfileValue.feedActionSetFilter,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionSetFilter: newValue),
            ),
          ),
          ListTileSelect(
            title: l(context).action_setSort,
            icon: Symbols.sort_rounded,
            selectionMenu: actionLocationSelect(context),
            value: ac.profile.feedActionSetSort,
            oldValue: ac.selectedProfileValue.feedActionSetSort,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionSetSort: newValue),
            ),
          ),
          ListTileSelect(
            title: l(context).action_setType,
            icon: Symbols.newspaper_rounded,
            selectionMenu: actionLocationWithTabsSelect(context),
            value: ac.profile.feedActionSetType,
            oldValue: ac.selectedProfileValue.feedActionSetType,
            onChange: (newValue) => ac.updateProfile(
              ac.selectedProfileValue
                  .cleanupActions(newValue.name, ac.profile)
                  .copyWith(feedActionSetType: newValue),
            ),
          ),
        ],
      ),
    );
  }
}
