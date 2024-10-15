import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/screens/explore/magazine_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/open_webpage.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

const _donateLink = 'https://github.com/sponsors/jwr1';
const _contributeLink = 'https://github.com/jwr1/interstellar';
const _translateLink =
    'https://hosted.weblate.org/projects/interstellar/interstellar/';
const _reportIssueLink = 'https://github.com/jwr1/interstellar/issues';
const _matrixSpaceLink = 'https://matrix.to/#/#interstellar-space:matrix.org';
const _mbinMagazineName = 'interstellar@kbin.earth';
const _mbinMagazineLink = 'https://kbin.earth/m/interstellar';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();

    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final newPackageInfo = await PackageInfo.fromPlatform();
    print(newPackageInfo.version);
    setState(() {
      packageInfo = newPackageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings_about_interstellar),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Symbols.favorite_rounded, fill: 0),
            title: Text(l(context).settings_about_donate),
            onTap: () => openWebpagePrimary(context, Uri.parse(_donateLink)),
          ),
          ListTile(
            leading: const ImageIcon(AssetImage('assets/icons/github.png')),
            title: Text(l(context).settings_about_contribute),
            onTap: () =>
                openWebpagePrimary(context, Uri.parse(_contributeLink)),
          ),
          ListTile(
            leading: const Icon(Symbols.translate_rounded, fill: 0),
            title: Text(l(context).settings_about_translate),
            onTap: () => openWebpagePrimary(context, Uri.parse(_translateLink)),
          ),
          ListTile(
            leading: const Icon(Symbols.bug_report_rounded, fill: 0),
            title: Text(l(context).settings_about_reportIssue),
            onTap: () =>
                openWebpagePrimary(context, Uri.parse(_reportIssueLink)),
          ),
          ListTile(
            leading: const ImageIcon(AssetImage('assets/icons/matrix.png')),
            title: Text(l(context).settings_about_matrixSpace),
            onTap: () =>
                openWebpagePrimary(context, Uri.parse(_matrixSpaceLink)),
          ),
          ListTile(
            leading: const ImageIcon(AssetImage('assets/icons/mbin.png')),
            title: Text(l(context).settings_about_mbinMagazine),
            onTap: () async {
              try {
                String name = _mbinMagazineName;
                if (name.endsWith(context.read<AppController>().instanceHost)) {
                  name = name.split('@').first;
                }

                final magazine = await context
                    .read<AppController>()
                    .api
                    .magazines
                    .getByName(name);

                if (!mounted) return;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        MagazineScreen(magazine.id, initData: magazine),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                openWebpagePrimary(context, Uri.parse(_mbinMagazineLink));
              }
            },
          ),
          const Divider(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Image.asset('assets/icons/logo-android-foreground.png'),
              ),
              Text(
                packageInfo == null
                    ? ''
                    : '${l(context).interstellar} v${packageInfo!.version}',
              ),
              const SizedBox(height: 36)
            ],
          )
        ],
      ),
    );
  }
}
