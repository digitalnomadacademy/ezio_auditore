library flutter_video_editor;

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/library_names.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/encoding_options.dart';
import 'package:flutter_video_editor/exceptions.dart';
import 'package:path_provider/path_provider.dart';

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
      {@required var videoPath,
      @required String outputPath,
      VideoCodec codec = VideoCodec.x264,
      int crf = 27,
      Preset preset = Preset.defaultPreset}) async {
    if (videoPath.isEmpty || outputPath.isEmpty) {
      throw InvalidArgumentException(
          'Video path and Output path cannot be empty');
    }

    final codecConfig = _getCodecConfig(codec, crf, preset);
    final Directory directory = await getApplicationDocumentsDirectory();
     String output;
    if (videoPath is List && videoPath.length > 1) {
      var file = File('${directory.path}/paths.txt');
      String text ="";
      videoPath.forEach((el){
        text+="file $el\n";
      });
     await file.writeAsString(text);
     output = file.path;
    } else
      output = videoPath.first;

    final script = _buildScript(
        videoPath: output,
        outputPath: outputPath,
        codecConfig: codecConfig,
        outputRate: 30);

    var executionResult = await _flutterFFmpeg.execute(script);

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

    /// For documentation regarding flags https://ffmpeg.org/ffmpeg.html#toc-Main-options
    return "-y ${videoPath.contains('txt')?"-f concat -safe 0":""} -i " +
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
