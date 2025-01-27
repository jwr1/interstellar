import 'dart:io';

import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/share.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as youtube_explode_dart;
import 'package:interstellar/src/controller/controller.dart';

bool isSupportedVideo(Uri link) {
  return ['www.youtube.com', 'youtube.com', 'youtu.be', 'm.youtube.com']
      .contains(link.host);
}

Future<youtube_explode_dart.MuxedStreamInfo> getVideoStream(Uri link) async {
  final yt = youtube_explode_dart.YoutubeExplode();

  final manifest = await yt.videos.streamsClient.getManifest(link);

  final stream = manifest.muxed.withHighestBitrate();

  return stream;
}

class VideoPlayer extends StatefulWidget {
  final Uri uri;

  const VideoPlayer(this.uri, {super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  final player = Player();
  late final controller = VideoController(player);
  late final youtube_explode_dart.MuxedStreamInfo? stream;

  Future<void> _initController() async {
    stream = null;
    if (isSupportedVideo(widget.uri)) {
      stream = await getVideoStream(widget.uri);
    }

    if (!mounted) {
      return;
    }
    player.open(
        Media(stream?.url.toString() ?? widget.uri.toString()),
        play: context.read<AppController>().profile.autoPlayVideo
    );
  }

  @override
  void initState() {
    _initController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
      child: Video(
        controller: controller,
        controls: (state) {
          return Stack(
            children: [
              media_kit_video_controls.AdaptiveVideoControls(state),
              if (!state.isFullscreen())
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingIconButton(
                        onPressed: () async {
                          final file = await downloadFile(
                            stream?.url ?? widget.uri,
                            'video-${stream?.videoId ??
                                widget.uri.pathSegments.last.split('.').first}'
                                '.${stream?.container ??
                                widget.uri.pathSegments.last.split('.').last}',
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('${l(context).videoSaved}: ${file.path}'),
                          ));
                        },
                        icon: const Icon(Symbols.download_rounded),
                      ),
                      if (!Platform.isLinux && stream != null)
                        LoadingIconButton(
                          onPressed: () async => await shareFile(stream!.url,
                              'video-${stream!.videoId}.${stream!.container}'),
                          icon: const Icon(Symbols.share_rounded),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ModalRoute.of(context)!.isCurrent) {
        player.pause();
      }
    });
  }

}
