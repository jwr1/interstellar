import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interstellar/src/widgets/loading_button.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as youtube_explode_dart;

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
  late final youtube_explode_dart.MuxedStreamInfo stream;

  Future<void> _initController() async {
    stream = await getVideoStream(widget.uri);

    player.open(Media(stream.url.toString()));
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
              if (!Platform.isLinux && !state.isFullscreen())
                Align(
                  alignment: Alignment.topRight,
                  child: LoadingIconButton(
                    onPressed: () async {
                      final response = await http.get(stream.url);

                      final tempDir = await getTemporaryDirectory();
                      final file = File(
                          '${tempDir.path}/video-${stream.videoId}.${stream.container}');
                      await file.writeAsBytes(response.bodyBytes);

                      await Share.shareXFiles([XFile(file.path)]);

                      await file.delete();
                    },
                    icon: const Icon(Icons.share),
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
}
