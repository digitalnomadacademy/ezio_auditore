library flutter_video_editor;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/exceptions.dart';
import 'package:flutter_video_editor/filters/drawtext_filter.dart';
import 'package:flutter_video_editor/script_builders/combine_script_builder.dart';
import 'package:flutter_video_editor/script_builders/simple_script_builder.dart';
import 'package:flutter_video_editor/utils/video_util.dart';
import 'package:flutter_video_editor/filters/watermark_filter.dart';
import 'package:path_provider/path_provider.dart';

/// Enums to represent different states of video output functions
enum VideoOutputState {
  success,
  failure,
}

/// VideoEditor class which will be used by our VideoViewer as well.
class VideoEditor {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();

  Future<String> setupFont() async {
    final filename = 'font.ttf';
    var bytes = await rootBundle
        .load("packages/flutter_video_editor/assets/font/aller.ttf");

    String dir = (await getApplicationDocumentsDirectory()).path;
    final path = '$dir/$filename';

    final buffer = bytes.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

    File file = File('$dir/$filename');

    print('Loaded file ${file.path}');
    _flutterFFmpegConfig.setFontDirectory(file.path, null);

    return file.path;
  }

  /// Function to encode a given video file with the required codec
  /// Watermark if needed must be passed as absolute file path
  Future<VideoOutputState> encodeVideo(
      {@required String videoPath,
      @required String outputPath,
      VideoCodec codec = VideoCodec.x264,
      String watermark = '',
      WatermarkPosition watermarkPosition = WatermarkPosition.bottomRight,
      int crf = 27,
      List<DrawTextFilter> textFilters = const [],
      Preset preset = Preset.defaultPreset}) async {
    if (videoPath.isEmpty || outputPath.isEmpty) {
      throw InvalidArgumentException(
          'Video path and Output path cannot be empty');
    }

    final codecConfig = CodecConfig.fromOptions(codec, crf, preset);

    final fontPath = await setupFont();
    var info = await VideoUtil().getVideoInfo(videoPath);

    final script = _buildScript(
        videoPath: videoPath,
        outputPath: outputPath,
        fontPath: fontPath,
        textFilters: textFilters,
        codecConfig: codecConfig,
        info: info,
        watermark: watermark,
        watermarkPosition: watermarkPosition,
        outputRate: 30);

    final executionResult = await _flutterFFmpeg.execute(script);

    if (executionResult == 0) {
      return VideoOutputState.success;
    }

    return VideoOutputState.failure;
  }

  /// Function to combine video files
  Future<VideoOutputState> combineVideos(
      {@required List<String> videoPaths,
      @required String outputPath,
      String watermark = '',
      WatermarkPosition watermarkPosition,
      List<DrawTextFilter> textFilters = const [],
      int crf = 27,
      Preset preset = Preset.defaultPreset}) async {
    if (videoPaths.length < 2 || outputPath.isEmpty) {
      throw InvalidArgumentException(
          'Video paths should be at least two and Output path cannot be empty');
    }

    //Check codecs of all videos, if they are different throw exception
    final videoUtil = VideoUtil();
    final videoInfo = await videoUtil.getVideoInfo(videoPaths[0]);
    final firstCodec = videoInfo.codec;

    for (final videoPath in videoPaths.sublist(1, videoPaths.length)) {
      var info = await videoUtil.getVideoInfo(videoPath);
      if (firstCodec != info.codec) {
        //Throw exception
        //In this scenario the video must first be encoded into desired format using encodeVideo and then be combined.
        throw CodecMismatchException(
            'Videos have different codec types. $videoPath has codec ${info.codec} which is not the same as $firstCodec');
      }
    }

    final fontPath = await setupFont();
    // Currently we base the video scale based on max available resolution among video paths
    final maxVideoInfo = await _getMaxVideoInfo(videoPaths);

    //Our codecs match, execute script
    final script = _buildScript(
      videoPaths: videoPaths,
      outputRate: 24,
      outputPath: outputPath,
      codec: firstCodec,
      watermark: watermark,
      textFilters: textFilters,
      info: maxVideoInfo,
      fontPath: fontPath,
      watermarkPosition: watermarkPosition,
      crf: crf,
      preset: preset,
    );

    final executionResult = await _flutterFFmpeg.execute(script);

    if (executionResult == 0) {
      return VideoOutputState.success;
    }

    return VideoOutputState.failure;
  }

  /// Private function to help generate scripts for ffmpeg
  /// Gives preference to CodecConfig if passed as an argument
  String _buildScript({
    String videoPath,
    List<String> videoPaths,
    String outputPath,
    String fontPath,
    VideoInfo info,
    CodecConfig codecConfig,
    String watermark = '',
    WatermarkPosition watermarkPosition = WatermarkPosition.bottomRight,
    VideoCodec codec,
    int outputRate,
    List<DrawTextFilter> textFilters,
    int crf,
    Preset preset,
  }) {
    // If multiple videoPaths are defined we build a combination script
    if (videoPaths != null && videoPaths.isNotEmpty) {
      final combineScript = CombineScriptBuilder(
        videoPaths: videoPaths,
        outputPath: outputPath,
        fontPath: fontPath,
        codecConfig: codecConfig,
        watermark: watermark,
        watermarkPosition: watermarkPosition,
        info: info,
        textFilters: textFilters,
        codec: codec,
        outputRate: outputRate,
        crf: crf,
        preset: preset,
      );

      return combineScript.build();
    }

    return SimpleScriptBuilder(
      videoPath: videoPath,
      outputPath: outputPath,
      fontPath: fontPath,
      codecConfig: codecConfig,
      watermark: watermark,
      watermarkPosition: watermarkPosition,
      codec: codec,
      outputRate: outputRate,
      textFilters: textFilters,
      crf: crf,
      info: info,
      preset: preset,
    ).build();
  }

  Future<VideoInfo> _getMaxVideoInfo(List<String> videoPaths) async {
    List<VideoInfo> videoInfos = List();
    for (var path in videoPaths) {
      videoInfos.add(await VideoUtil().getVideoInfo(path));
    }

    final videoInfo = videoInfos.reduce((infoOne, otherInfo) =>
        infoOne.totalPixels > otherInfo.totalPixels ? infoOne : otherInfo);

    return videoInfo;
  }
}
