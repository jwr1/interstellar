import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    as youtube_explode_dart;

bool isSupportedVideo(String link) {
  return ['www.youtube.com', 'youtube.com', 'youtu.be', 'm.youtube.com']
      .contains(Uri.parse(link).host);
}

Future<Uri> getVideoStreamUri(Uri link) async {
  var yt = youtube_explode_dart.YoutubeExplode();

  var manifest = await yt.videos.streamsClient.getManifest(link);

  return manifest.muxed.withHighestBitrate().url;
}

class VideoPlayer extends StatefulWidget {
  final Uri uri;

  const VideoPlayer(this.uri, {super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  Future<void> _initController() async {
    player.open(Media((await getVideoStreamUri(widget.uri)).toString()));
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
      child: Video(controller: controller),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
