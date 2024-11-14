import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/api/feed_source.dart';
import 'package:interstellar/src/models/post.dart';
import 'package:interstellar/src/widgets/actions.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

enum OpenLinksIn { inAppBrowser, externalBrowser }

/// Profile class where all fields are required.
@freezed
class ProfileRequired with _$ProfileRequired {
  const ProfileRequired._();

  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory ProfileRequired({
    // If the autoSwitchAccount key is ever changed, be sure to update the AppController code that removes accounts, which references this key.
    required String? autoSwitchAccount,
    // Behavior settings
    required String defaultPostLanguage,
    required bool useAccountLanguageFilter,
    required List<String> customLanguageFilter,
    required bool addAltTextReminders,
    required bool autoplayAnimatedImages,
    required bool disableTabSwiping,
    required bool askBeforeUnsubscribing,
    required bool askBeforeDeleting,
    // Display settings
    required ThemeMode themeMode,
    required FlexScheme colorScheme,
    required bool enableTrueBlack,
    required bool compactMode,
    required bool alwaysShowInstance,
    required bool alwaysRevealContentWarnings,
    required bool coverMediaMarkedSensitive,
    // Feed defaults
    required PostType feedDefaultType,
    required FeedSource feedDefaultFilter,
    required FeedSort feedDefaultThreadsSort,
    required FeedSort feedDefaultMicroblogSort,
    required FeedSort feedDefaultExploreSort,
    required CommentSort feedDefaultCommentSort,
    // Feed actions
    required ActionLocation feedActionBackToTop,
    required ActionLocation feedActionCreatePost,
    required ActionLocation feedActionExpandFab,
    required ActionLocation feedActionRefresh,
    required ActionLocationWithTabs feedActionSetFilter,
    required ActionLocation feedActionSetSort,
    required ActionLocationWithTabs feedActionSetType,
  }) = _ProfileRequired;

  factory ProfileRequired.fromJson(Map<String, Object?> json) =>
      _$ProfileRequiredFromJson(json);

  factory ProfileRequired.fromOptional(ProfileOptional? profile) =>
      ProfileRequired(
        autoSwitchAccount: profile?.autoSwitchAccount,
        defaultPostLanguage:
            profile?.defaultPostLanguage ?? defaultProfile.defaultPostLanguage,
        useAccountLanguageFilter: profile?.useAccountLanguageFilter ??
            defaultProfile.useAccountLanguageFilter,
        customLanguageFilter: profile?.customLanguageFilter ??
            defaultProfile.customLanguageFilter,
        addAltTextReminders:
            profile?.addAltTextReminders ?? defaultProfile.addAltTextReminders,
        autoplayAnimatedImages: profile?.autoplayAnimatedImages ??
            defaultProfile.autoplayAnimatedImages,
        disableTabSwiping:
            profile?.disableTabSwiping ?? defaultProfile.disableTabSwiping,
        askBeforeUnsubscribing: profile?.askBeforeUnsubscribing ??
            defaultProfile.askBeforeUnsubscribing,
        askBeforeDeleting:
            profile?.askBeforeDeleting ?? defaultProfile.askBeforeDeleting,
        themeMode: profile?.themeMode ?? defaultProfile.themeMode,
        colorScheme: profile?.colorScheme ?? defaultProfile.colorScheme,
        enableTrueBlack:
            profile?.enableTrueBlack ?? defaultProfile.enableTrueBlack,
        compactMode: profile?.compactMode ?? defaultProfile.compactMode,
        alwaysShowInstance:
            profile?.alwaysShowInstance ?? defaultProfile.alwaysShowInstance,
        alwaysRevealContentWarnings: profile?.alwaysRevealContentWarnings ??
            defaultProfile.alwaysRevealContentWarnings,
        coverMediaMarkedSensitive: profile?.coverMediaMarkedSensitive ??
            defaultProfile.coverMediaMarkedSensitive,
        feedDefaultType:
            profile?.feedDefaultType ?? defaultProfile.feedDefaultType,
        feedDefaultFilter:
            profile?.feedDefaultFilter ?? defaultProfile.feedDefaultFilter,
        feedDefaultThreadsSort: profile?.feedDefaultThreadsSort ??
            defaultProfile.feedDefaultThreadsSort,
        feedDefaultMicroblogSort: profile?.feedDefaultMicroblogSort ??
            defaultProfile.feedDefaultMicroblogSort,
        feedDefaultExploreSort: profile?.feedDefaultExploreSort ??
            defaultProfile.feedDefaultExploreSort,
        feedDefaultCommentSort: profile?.feedDefaultCommentSort ??
            defaultProfile.feedDefaultCommentSort,
        feedActionBackToTop:
            profile?.feedActionBackToTop ?? defaultProfile.feedActionBackToTop,
        feedActionCreatePost: profile?.feedActionCreatePost ??
            defaultProfile.feedActionCreatePost,
        feedActionExpandFab:
            profile?.feedActionExpandFab ?? defaultProfile.feedActionExpandFab,
        feedActionRefresh:
            profile?.feedActionRefresh ?? defaultProfile.feedActionRefresh,
        feedActionSetFilter:
            profile?.feedActionSetFilter ?? defaultProfile.feedActionSetFilter,
        feedActionSetSort:
            profile?.feedActionSetSort ?? defaultProfile.feedActionSetSort,
        feedActionSetType:
            profile?.feedActionSetType ?? defaultProfile.feedActionSetType,
      );

  static const defaultProfile = ProfileRequired(
    autoSwitchAccount: null,
    defaultPostLanguage: 'en',
    useAccountLanguageFilter: true,
    customLanguageFilter: [],
    addAltTextReminders: true,
    autoplayAnimatedImages: true,
    disableTabSwiping: false,
    askBeforeUnsubscribing: false,
    askBeforeDeleting: true,
    themeMode: ThemeMode.system,
    colorScheme: FlexScheme.custom,
    enableTrueBlack: false,
    compactMode: false,
    alwaysShowInstance: false,
    alwaysRevealContentWarnings: false,
    coverMediaMarkedSensitive: true,
    feedDefaultType: PostType.thread,
    feedDefaultFilter: FeedSource.subscribed,
    feedDefaultThreadsSort: FeedSort.hot,
    feedDefaultMicroblogSort: FeedSort.hot,
    feedDefaultExploreSort: FeedSort.newest,
    feedDefaultCommentSort: CommentSort.hot,
    feedActionBackToTop: ActionLocation.fabMenu,
    feedActionCreatePost: ActionLocation.fabMenu,
    feedActionExpandFab: ActionLocation.fabTap,
    feedActionRefresh: ActionLocation.fabMenu,
    feedActionSetFilter: ActionLocationWithTabs.tabs,
    feedActionSetSort: ActionLocation.appBar,
    feedActionSetType: ActionLocationWithTabs.appBar,
  );
}

/// Profile class where all fields are optional.
@freezed
class ProfileOptional with _$ProfileOptional {
  const ProfileOptional._();

  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory ProfileOptional({
    required String? autoSwitchAccount,
    // Behavior settings
    required String? defaultPostLanguage,
    required bool? useAccountLanguageFilter,
    required List<String>? customLanguageFilter,
    required bool? addAltTextReminders,
    required bool? autoplayAnimatedImages,
    required bool? disableTabSwiping,
    required bool? askBeforeUnsubscribing,
    required bool? askBeforeDeleting,
    // Display settings
    required ThemeMode? themeMode,
    required FlexScheme? colorScheme,
    required bool? enableTrueBlack,
    required bool? compactMode,
    required bool? alwaysShowInstance,
    required bool? alwaysRevealContentWarnings,
    required bool? coverMediaMarkedSensitive,
    // Feed defaults
    required PostType? feedDefaultType,
    required FeedSource? feedDefaultFilter,
    required FeedSort? feedDefaultThreadsSort,
    required FeedSort? feedDefaultMicroblogSort,
    required FeedSort? feedDefaultExploreSort,
    required CommentSort? feedDefaultCommentSort,
    // Feed actions
    required ActionLocation? feedActionBackToTop,
    required ActionLocation? feedActionCreatePost,
    required ActionLocation? feedActionExpandFab,
    required ActionLocation? feedActionRefresh,
    required ActionLocationWithTabs? feedActionSetFilter,
    required ActionLocation? feedActionSetSort,
    required ActionLocationWithTabs? feedActionSetType,
  }) = _ProfileOptional;

  factory ProfileOptional.fromJson(Map<String, Object?> json) =>
      _$ProfileOptionalFromJson(json);

  static const nullProfile = ProfileOptional(
    autoSwitchAccount: null,
    defaultPostLanguage: null,
    useAccountLanguageFilter: null,
    customLanguageFilter: null,
    addAltTextReminders: null,
    autoplayAnimatedImages: null,
    disableTabSwiping: null,
    askBeforeUnsubscribing: null,
    askBeforeDeleting: null,
    themeMode: null,
    colorScheme: null,
    enableTrueBlack: null,
    compactMode: null,
    alwaysShowInstance: null,
    alwaysRevealContentWarnings: null,
    coverMediaMarkedSensitive: null,
    feedDefaultType: null,
    feedDefaultFilter: null,
    feedDefaultThreadsSort: null,
    feedDefaultMicroblogSort: null,
    feedDefaultExploreSort: null,
    feedDefaultCommentSort: null,
    feedActionBackToTop: null,
    feedActionCreatePost: null,
    feedActionExpandFab: null,
    feedActionRefresh: null,
    feedActionSetFilter: null,
    feedActionSetSort: null,
    feedActionSetType: null,
  );

  ProfileOptional merge(ProfileOptional? other) {
    if (other == null) return this;

    return ProfileOptional(
      autoSwitchAccount: other.autoSwitchAccount,
      defaultPostLanguage: other.defaultPostLanguage ?? defaultPostLanguage,
      useAccountLanguageFilter:
          other.useAccountLanguageFilter ?? useAccountLanguageFilter,
      customLanguageFilter: other.customLanguageFilter ?? customLanguageFilter,
      addAltTextReminders: other.addAltTextReminders ?? addAltTextReminders,
      autoplayAnimatedImages:
          other.autoplayAnimatedImages ?? autoplayAnimatedImages,
      disableTabSwiping: other.disableTabSwiping ?? disableTabSwiping,
      askBeforeUnsubscribing:
          other.askBeforeUnsubscribing ?? askBeforeUnsubscribing,
      askBeforeDeleting: other.askBeforeDeleting ?? askBeforeDeleting,
      themeMode: other.themeMode ?? themeMode,
      colorScheme: other.colorScheme ?? colorScheme,
      enableTrueBlack: other.enableTrueBlack ?? enableTrueBlack,
      compactMode: other.compactMode ?? compactMode,
      alwaysShowInstance: other.alwaysShowInstance ?? alwaysShowInstance,
      alwaysRevealContentWarnings:
          other.alwaysRevealContentWarnings ?? alwaysRevealContentWarnings,
      coverMediaMarkedSensitive:
          other.coverMediaMarkedSensitive ?? coverMediaMarkedSensitive,
      feedDefaultType: other.feedDefaultType ?? feedDefaultType,
      feedDefaultFilter: other.feedDefaultFilter ?? feedDefaultFilter,
      feedDefaultThreadsSort:
          other.feedDefaultThreadsSort ?? feedDefaultThreadsSort,
      feedDefaultMicroblogSort:
          other.feedDefaultMicroblogSort ?? feedDefaultMicroblogSort,
      feedDefaultExploreSort:
          other.feedDefaultExploreSort ?? feedDefaultExploreSort,
      feedDefaultCommentSort:
          other.feedDefaultCommentSort ?? feedDefaultCommentSort,
      feedActionBackToTop:
          other.feedActionBackToTop ?? this.feedActionBackToTop,
      feedActionCreatePost:
          other.feedActionCreatePost ?? this.feedActionCreatePost,
      feedActionExpandFab:
          other.feedActionExpandFab ?? this.feedActionExpandFab,
      feedActionRefresh: other.feedActionRefresh ?? this.feedActionRefresh,
      feedActionSetFilter:
          other.feedActionSetFilter ?? this.feedActionSetFilter,
      feedActionSetSort: other.feedActionSetSort ?? this.feedActionSetSort,
      feedActionSetType: other.feedActionSetType ?? this.feedActionSetType,
    );
  }
}
