# Interstellar

An app for Kbin; connecting you to the fediverse.

## Installation

At the moment, Interstellar can be tested on both Linux and Android (you could also build from source for other platforms). You'll find the latest build files [here](https://github.com/jwr1/interstellar/releases/latest).

## Discussion

You can ask questions, report bugs, or make suggestions either here on [GitHub](https://github.com/jwr1/interstellar/issues), or in the [interstellar magazine](https://kbin.earth/m/interstellar). You can also join the [matrix room](https://matrix.to/#/#kbin-interstellar:matrix.org) for real time discussion.

## Contributing

Interstellar uses [Flutter](https://flutter.dev) as its framework, so make sure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install) before doing anything else. Then, run `flutter doctor -v` to see instructions for setting up different build platforms (e.g. android studio for APKs). Once that's done, use `dart run build_runner build` to build the generated code for models (this only needs to run once unless you modify one of the models). Finally, you can use `flutter run` to develop, and `flutter build {platform}` for release files.

### Generating app icon

The app icon is under the `assets/icons` folder, where the `logo.png` file is just the transparent one overlayed on the current background color `#423862`. This is generated with the [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) package, and all relevant configuration is in the `pubspec.yaml` file.

Icons created by [Benjamin Mathis](https://github.com/BenjMathis1)

To generate a new icon, simply run from the project root:

```
dart flutter pub get
dart pub run flutter_launcher_icons
```
