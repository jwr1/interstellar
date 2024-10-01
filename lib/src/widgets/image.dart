import 'dart:io';
import 'dart:math';

import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/models/image.dart';
import 'package:interstellar/src/widgets/blur.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AdvancedImage extends StatelessWidget {
  final ImageModel image;
  final BoxFit fit;
  final String? openTitle;
  final bool enableBlur;

  const AdvancedImage(
    this.image, {
    super.key,
    this.fit = BoxFit.contain,
    this.openTitle,
    this.enableBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final blurHashSizeFactor = image.blurHash == null
        ? null
        : sqrt(1080 / (image.blurHashWidth! * image.blurHashHeight!));

    return Wrapper(
      shouldWrap: openTitle != null,
      parentBuilder: (child) => GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdvancedImagePage(
                image,
                title: openTitle!,
              ),
            ),
          );
        },
        child: child,
      ),
      child: Wrapper(
        shouldWrap: enableBlur,
        parentBuilder: (child) => Blur(child),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: [
            if (image.blurHash != null)
              Image(
                fit: fit,
                image: BlurhashFfiImage(
                  image.blurHash!,
                  decodingWidth:
                      (blurHashSizeFactor! * image.blurHashWidth!).ceil(),
                  decodingHeight:
                      (blurHashSizeFactor * image.blurHashHeight!).ceil(),
                  scale: blurHashSizeFactor,
                ),
              ),
            Image.network(
              image.src,
              fit: fit,
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedImagePage extends StatelessWidget {
  final ImageModel image;
  final String title;

  const AdvancedImagePage(this.image, {super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    const shadows = <Shadow>[
      Shadow(color: Colors.black, blurRadius: 1.0, offset: Offset(0, 1))
    ];

    final titleStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(shadows: shadows);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: titleStyle),
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: shadows,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (!Platform.isLinux)
            IconButton(
              onPressed: () async {
                final response = await http.get(Uri.parse(image.src));

                final tempDir = await getTemporaryDirectory();
                final file =
                    File('${tempDir.path}/${image.src.split('/').last}');
                await file.writeAsBytes(response.bodyBytes);

                await Share.shareXFiles([XFile(file.path)]);

                await file.delete();
              },
              icon: const Icon(Icons.share),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: AdvancedImage(image),
            ),
          ),
          if (image.altText != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  image.altText!,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
