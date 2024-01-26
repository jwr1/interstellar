import 'package:flutter/material.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';

enum CommentSort { newest, top, hot, active, oldest }

const SelectionMenu<CommentSort> commentSortSelect = SelectionMenu(
  'Sort Comments',
  [
    SelectionMenuItem(
      value: CommentSort.hot,
      title: 'Hot',
      icon: Icons.local_fire_department,
    ),
    SelectionMenuItem(
      value: CommentSort.top,
      title: 'Top',
      icon: Icons.trending_up,
    ),
    SelectionMenuItem(
      value: CommentSort.newest,
      title: 'Newest',
      icon: Icons.auto_awesome_rounded,
    ),
    SelectionMenuItem(
      value: CommentSort.active,
      title: 'Active',
      icon: Icons.rocket_launch,
    ),
    SelectionMenuItem(
      value: CommentSort.oldest,
      title: 'Oldest',
      icon: Icons.access_time_outlined,
    ),
  ],
);
