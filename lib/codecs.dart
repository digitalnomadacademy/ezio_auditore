import 'package:flutter_video_editor/constants/library_names.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/encoding_options.dart';

enum VideoCodec {
  x264, //Used to represent Advanced Video Coding (AVC), also referred to as H.264 or MPEG-4
  x265, //Used to represent High Efficiency Video Coding (HEVC), also known as H.265 and MPEG-H Part 2
}

class CodecConfig {
  final String libraryName;
  final String encodingOptions;

  const CodecConfig({
    this.libraryName,
    this.encodingOptions,
  }) : assert(libraryName != null &&
            libraryName != '' &&
            encodingOptions != null);

  /// Returns codec config for video output, should be private as used internally only
  factory CodecConfig.fromOptions(VideoCodec codec, int crf, Preset preset) {
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
}
