library flutter_video_editor;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/exceptions.dart';
import 'package:flutter_video_editor/script_builders/combine_script_builder.dart';
import 'package:flutter_video_editor/script_builders/watermark_script_builder.dart';
import 'package:flutter_video_editor/video_util.dart';
import 'package:flutter_video_editor/watermark_filter.dart';
import 'package:path_provider/path_provider.dart';

/// Enums to represent different states of video output functions
enum VideoOutputState {
  success,
  failure,
}

/// VideoEditor class which will be used by our VideoViewer as well.
class VideoEditor {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
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
      Preset preset = Preset.defaultPreset}) async {
    if (videoPath.isEmpty || outputPath.isEmpty) {
      throw InvalidArgumentException(
          'Video path and Output path cannot be empty');
    }

    final codecConfig = CodecConfig.fromOptions(codec, crf, preset);

    final fontPath = await setupFont();

    final script = _buildScript(
        videoPath: videoPath,
        outputPath: outputPath,
        fontPath: fontPath,
        codecConfig: codecConfig,
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
      watermark: watermark,
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

  // Todo: Build this method along as we add more functionality
  /// Private function to help generate scripts for ffmpeg
  /// Gives preference to CodecConfig if passed as an argument
  String _buildScript({
    String videoPath,
    List<String> videoPaths,
    String outputPath,
    String fontPath,
    CodecConfig codecConfig,
    String watermark = '',
    WatermarkPosition watermarkPosition = WatermarkPosition.bottomRight,
    VideoCodec codec,
    int outputRate,
    int crf,
    Preset preset,
  }) {
    var _codecConfig = codecConfig;

    if (codecConfig == null) {
      _codecConfig = CodecConfig.fromOptions(codec, crf, preset);
    }

    // If multiple videoPaths are defined we build a combination script
    if (videoPaths != null && videoPaths.isNotEmpty) {
      final combineScript = CombineScriptBuilder(
        videoPaths: videoPaths,
        outputPath: outputPath,
        fontPath: fontPath,
        codecConfig: codecConfig,
        watermark: watermark,
        watermarkPosition: watermarkPosition,
        codec: codec,
        outputRate: outputRate,
        crf: crf,
        preset: preset,
      );

      return combineScript.build();
    }

    final watermarkFilter = WatermarkScriptBuilder(
            watermark: watermark,
            watermarkPosition: watermarkPosition,
            withFilter: false)
        .build();

    /// For documentation regarding flags https://ffmpeg.org/ffmpeg.html#toc-Main-options
    return "-y -i " +
        videoPath +
        " " +
        watermarkFilter.input +
        //watermarkFilter.complexFilter +
        "-filter_complex \"[0:v][1:v]${watermarkFilter.complexFilter},drawtext=fontfile='$fontPath':fontsize=90:x=20:y=20:text='Testing':enable='between(t\\,1\\,2)'\" " +
        //watermarkFilter.complexFilter +
        //" " +
        _codecConfig.encodingOptions +
        " " +
        "-c:v " +
        _codecConfig.libraryName +
        " -r $outputRate " +
        outputPath;
  }
}

/// ffmpeg -i input -filter_complex "drawtext=text='Summer Video':enable='between(t,15,20)',
/// fade=t=in:start_time=15:d=0.5:alpha=1,fade=t=out:start_time=19.5:d=0.5:alpha=1[fg];
/// [0][fg]overlay=format=auto,format=yuv420p" -c:a copy output.mp4
///
/// ffmpeg -i input.mp4 -vf drawtext="fontfile=/path/to/font.ttf: \
/// text='Stack Overflow': fontcolor=white: fontsize=24: box=1: boxcolor=black@0.5: \
/// boxborderw=5: x=(w-text_w)/2: y=(h-text_h)/2" -codec:a copy output.mp4

/*

```
ffmpeg -i video.mp4 -i logo.png -filter_complex
"[0:v][1:v]overlay=10:10,drawtext=text='Hello World'" -c:a copy -movflags +faststart output.mp4

```

Just chain the drawtext, at the end.

ffmpeg \
-i video1.mp4 -i video2.mp4
-filter_complex "[0:v:0] [0:a:0] [0:v:1] [0:a:1] concat=n=2:v=1:a=1 [v][a];
[v]drawtext=text='SOME TEXT':x=(w-text_w):y=(h-text_h):fontfile=OpenSans.ttf:fontsize=30:fontcolor=white[v]" \
-map "[v]" -map "[a]" -deinterlace \
-vcodec libx264 -pix_fmt yuv420p -preset $QUAL -r $FPS -g $(($FPS * 2)) -b:v $VBR \
-acodec libmp3lame -ar 44100 -threads 6 -qscale 3 -b:a 712000 -bufsize 512k \
-f flv "$YOUTUBE_URL/$KEY"
*/

/*
ffmpeg -loop 1 -i mic720x1280.png -i waves5.mp4
-filter_complex "color=0x000000@0,format=gbrap[bg];[0]format=gbrap,drawtext=fontfile=Montserrat-Bold.ttf:
text='Hello': fontcolor=white: fontsize=44: box=1: boxcolor=black@0.5: boxborderw=10: x=(w-text_w)/2:
y=100,setsar=1[img];[bg][img]scale2ref[bg][img];[bg]setsar=1[bg];[1]scale=500:-1,format=gbrap[vid];
[bg][vid]overlay=70:70:format=rgb[vidbl];[vidbl][img]blend=all_mode=addition" -c:v libx264 -t 15
-pix_fmt yuv420p myvid.mp4
* */

/*
ffmpeg -i i.mp4 -i watermarkfile.png -filter_complex \
"[0:v]drawtext=text='TESTING':fontcolor=black@1.0:fontsize=36:x=00:y=40[text]; \
[text][1:v]overlay[filtered]" -map "[filtered]" \
-map 0:a -codec:v libx264 -codec:a copy output.mp4
* */
