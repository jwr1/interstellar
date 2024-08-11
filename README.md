# Interstellar

An app for Mbin and Lemmy; connecting you to the fediverse.

## Downloads

[![](assets/readme/GooglePlay-badge.png)](https://play.google.com/store/apps/details?id=one.jwr.interstellar)
[![](assets/readme/IzzyOnDroid-badge.png)](https://apt.izzysoft.de/fdroid/index/apk/one.jwr.interstellar)
[![](assets/readme/Flathub-badge.png)](https://flathub.org/apps/one.jwr.interstellar)

See the [latest release](https://github.com/jwr1/interstellar/releases/latest) for direct APK files, an AppImage, and more platforms.

## Discussion

You can ask questions, report bugs, make suggestions, etc., to any of the following:

- [GitHub](https://github.com/jwr1/interstellar/issues)
- [Mbin](https://kbin.earth/m/interstellar)
- [Matrix](https://matrix.to/#/#interstellar-space:matrix.org)

## Screenshots

<div align="center">
<img src="assets/screenshots/desktop-3.png"  width="800"></img>
<img src="assets/screenshots/desktop-2.png"  width="800"></img>
<br>
<img src="assets/screenshots/mobile-1.png" width="300"></img>
<img src="assets/screenshots/mobile-2.png"  width="300"></img>
</div>

## Contributing

Interstellar uses [Flutter](https://flutter.dev) as its framework, so make sure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install) before doing anything else. Then, run `flutter doctor -v` to see instructions for setting up different build platforms (e.g. android studio for APKs). Once that's done, use `dart run build_runner build` to build the generated code for models (this only needs to run once unless you modify one of the models). Finally, you can use `flutter run` to develop, and `flutter build {platform}` for release files.

### Generating app icon

The app icon is under the `assets/icons` folder, where the `logo.png` file is just the transparent one overlayed on the current background color `#423862`. This is generated with the [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) package, and all relevant configuration is in the `pubspec.yaml` file.

Icons created by [Benjamin Mathis](https://github.com/BenjMathis1)

To generate a new icon, simply run the following: `dart run flutter_launcher_icons`
