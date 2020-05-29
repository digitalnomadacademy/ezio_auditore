library flutter_video_editor;

import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/exceptions.dart';

/// Enums to represent different states of video output functions
enum VideoOutputState {
  success,
  failure,
}

/// VideoEditor class which will be used by our VideoViewer as well.
class VideoEditor {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  /// Returns codec config for video output, should be private
  /// as used internally only

  //Todo: Make encoding options into a class as well, with arguments that have meaningful enum representations
  CodecConfig _getCodecConfig(Codec codec) {
    switch (codec) {
      case Codec.x264:
        return CodecConfig(
            libraryName: 'libx264',
            encodingOptions: '-crf 27 -preset veryfast ');

      case Codec.x265:
        return CodecConfig(
            libraryName: 'libx265',
            encodingOptions: '-crf 28 -preset veryfast ');

      default:
        return CodecConfig(
            libraryName: 'libx264',
            encodingOptions: '-crf 27 -preset veryfast ');
    }
  }

  /// Function to encode a given video file with the required codec
  Future<VideoOutputState> encodeVideo(
      {@required String videoPath,
      @required String outputPath,
      Codec codec = Codec.x264}) async {
    if (videoPath.isEmpty || outputPath.isEmpty) {
      throw InvalidArgumentException(
          'Video path and Output path cannot be empty');
    }

    final codecConfig = _getCodecConfig(codec);

    //Todo: Replace with script builder which takes arguments
    final script = "-y -i " +
        videoPath +
        " " +
        codecConfig.encodingOptions +
        " " +
        "-c:v " +
        codecConfig.libraryName +
        " -r 30 " +
        outputPath;

    //Todo: Replace with logger
    print(script);

    var executionResult = await _flutterFFmpeg.execute(script);

    if (executionResult == 0) {
      return VideoOutputState.success;
    }

    return VideoOutputState.failure;
  }
}
