library flutter_video_editor;

import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/library_names.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/encoding_options.dart';
import 'package:flutter_video_editor/exceptions.dart';
import 'package:flutter_video_editor/video_util.dart';

/// Enums to represent different states of video output functions
enum VideoOutputState {
  success,
  failure,
}

/// VideoEditor class which will be used by our VideoViewer as well.
class VideoEditor {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  /// Returns codec config for video output, should be private as used internally only
  CodecConfig _getCodecConfig(VideoCodec codec, int crf, Preset preset) {
    final encodingOptions =
        EncodingOptions(crf: crf, preset: preset).generate();

    switch (codec) {
      case VideoCodec.x264:
        return CodecConfig(
            libraryName: LibraryNames.h264, encodingOptions: encodingOptions);

      case VideoCodec.x265:
        return CodecConfig(
            libraryName: LibraryNames.h265, encodingOptions: encodingOptions);

      default:
        return CodecConfig(
            libraryName: LibraryNames.h264, encodingOptions: encodingOptions);
    }
  }

  /// Function to encode a given video file with the required codec
  Future<VideoOutputState> encodeVideo(
      {@required String videoPath,
      @required String outputPath,
      VideoCodec codec = VideoCodec.x264,
      int crf = 27,
      Preset preset = Preset.defaultPreset}) async {
    if (videoPath.isEmpty || outputPath.isEmpty) {
      throw InvalidArgumentException(
          'Video path and Output path cannot be empty');
    }

    final codecConfig = _getCodecConfig(codec, crf, preset);

    final script = _buildScript(
        videoPath: videoPath,
        outputPath: outputPath,
        codecConfig: codecConfig,
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

    //Our codecs match, execute script
    final script = _buildScript(
      videoPaths: videoPaths,
      outputRate: 24,
      outputPath: outputPath,
      codec: firstCodec,
      crf: crf,
      preset: preset,
    );

    final executionResult = await _flutterFFmpeg.execute(script);

    if (executionResult == 0) {
      return VideoOutputState.success;
    }

    return VideoOutputState.failure;
  }

  // Todo: Build this method along as we add more functionality
  /// Private function to help generate scripts for ffmpeg
  /// Gives preference to CodecConfig if passed as an argument
  String _buildScript({
    String videoPath,
    List<String> videoPaths,
    String outputPath,
    CodecConfig codecConfig,
    VideoCodec codec,
    int outputRate,
    int crf,
    Preset preset,
  }) {
    var _codecConfig = codecConfig;

    if (codecConfig == null) {
      _codecConfig = _getCodecConfig(codec, crf, preset);
    }

    //If multiple videoPaths are defined we build a combination script
    if (videoPaths != null && videoPaths.isNotEmpty) {
      var combineScript = '-y ';
      for (final path in videoPaths) {
        combineScript += '-i ' + path + ' ';
      }

      combineScript += '-filter_complex "';
      for (var i = 0; i < videoPaths.length; i++) {
        combineScript += '[$i:v]scale=720:1280:force_original_aspect_ratio=1[v$i] ';
      }

      for (var i = 0; i < videoPaths.length; i++) {
        combineScript += '[v$i][$i:a]';
      }
      combineScript +=
          'concat=unsafe=1:n=${videoPaths.length}:v=1:a=1 [v] [a]" -map [v] -map [a] ';

      combineScript += _codecConfig.encodingOptions + ' -vsync 2 -r $outputRate ';

      combineScript += outputPath;

      return combineScript;
    }

    /// For documentation regarding flags https://ffmpeg.org/ffmpeg.html#toc-Main-options
    return "-y -i " +
        videoPath +
        " " +
        _codecConfig.encodingOptions +
        " " +
        "-c:v " +
        _codecConfig.libraryName +
        " -r $outputRate " +
        outputPath;
  }
}
