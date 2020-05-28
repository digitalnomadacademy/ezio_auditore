library fluttervideoeditor;

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:fluttervideoeditor/codecs.dart';
import 'package:path_provider/path_provider.dart';

/// VideoEditor class which will be used by our VideoViewer as well.
class VideoEditor {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  /// Returns codec config for video output, should be private
  /// as used internally only
  CodecConfig _getCodecConfig(Codec codec) {
    switch (codec) {
      case Codec.x264:
        return CodecConfig(libraryName: 'libx264', encodingOptions: '-crf 27 -preset veryfast ');

      case Codec.x265:
        return CodecConfig(
            libraryName: 'libx265', encodingOptions: '-crf 28 -preset veryfast ');
    }
  }

  /// Function to encode a given video file with the required codec
  Future<int> encodeVideo(String videoPath, Codec codec) async {
    //Get temp file path
    var tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/temp.mp4';

    final codecConfig = _getCodecConfig(codec);

    final script = "-y -i " +
        videoPath +
        " " +
        codecConfig.encodingOptions +
        " " +
        "-c:v " +
        codecConfig.libraryName +
        " -r 30 " +
        tempPath;

    print(script);

    return _flutterFFmpeg.execute(script);
  }
}
