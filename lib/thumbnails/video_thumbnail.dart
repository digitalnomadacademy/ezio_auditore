import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_editor/thumbnails/thumbnail_format.dart';
import 'package:flutter_video_editor/video_util.dart';

class VideoThumbnail {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final VideoUtil _videoUtil = VideoUtil();

  /// Video thumbnail is written to output path in required format. PNG by default.
  /// Generated thumbnail is taken from middle for the video
  Future<String> getThumbnailForVideo(
      {String videoPath,
      ThumbnailFormat format = ThumbnailFormat.png,
      String outputPath}) async {
    // Get total duration of video
    final videoInfo = await _videoUtil.getVideoInfo(videoPath);
    final duration = _formattedDuration((videoInfo.duration / 2000).floor());

    final filename = '${DateTime.now().toIso8601String()}.${format.name}';
    final thumbnailPath = '$outputPath$filename';

    await _flutterFFmpeg.execute(
        '-ignore_editlist 1 -i $videoPath -ss $duration -vframes 1 $thumbnailPath');

    return thumbnailPath;
  }

  String _formattedDuration(int duration) {
    print('Duration: $duration');
    final hours = (duration / 3600).floor().toString().padLeft(2, '0');
    final minutes = ((duration / 60).floor() % 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds.000';
  }
}
