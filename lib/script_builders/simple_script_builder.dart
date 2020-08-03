import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/script_builders/base_script_builder.dart';
import 'package:flutter_video_editor/script_builders/watermark_script_builder.dart';
import 'package:flutter_video_editor/watermark_filter.dart';

class SimpleScriptBuilder implements BaseScriptBuilder {
  final String videoPath;
  final String outputPath;
  final String fontPath;
  final CodecConfig codecConfig;
  final String watermark;
  final WatermarkPosition watermarkPosition;
  final VideoCodec codec;
  final int outputRate;
  final int crf;
  final Preset preset;

  const SimpleScriptBuilder({
    this.videoPath,
    this.outputPath,
    this.fontPath,
    this.codecConfig,
    this.watermark = '',
    this.watermarkPosition = WatermarkPosition.bottomRight,
    this.codec,
    this.outputRate,
    this.crf,
    this.preset,
  });

  @override
  String build() {
    var _codecConfig = codecConfig;

    if (codecConfig == null) {
      _codecConfig = CodecConfig.fromOptions(codec, crf, preset);
    }

    final watermarkFilter = WatermarkScriptBuilder(
            watermark: watermark,
            watermarkPosition: watermarkPosition,
            withFilter: false)
        .build();

    /// For documentation regarding flags https://ffmpeg.org/ffmpeg.html#toc-Main-options

    // Todo: Separate scripts for cases 1: With watermark and text, 2: Text only
    return "-y -i " +
        videoPath +
        " " +
        watermarkFilter.input +
        "-filter_complex \"[0:v][1:v]${watermarkFilter.complexFilter},drawtext=fontfile='$fontPath':fontsize=90:x=20:y=20:text='Testing':enable='between(t\\,1\\,2)',drawbox=enable='between(t\\,3\\,4)':y=ih-h:color=black:width=iw:height=350:t=fill,drawtext=fontfile='$fontPath':fontsize=90:fontcolor=white:x=(w-text_w)/2:y=h-th:text='OTHER TEXT LONG SUPER\n LONG LONG LONG':enable='between(t\\,3\\,4)'\" " +

        // watermarkFilter.complexFilter +
        //" " +
        _codecConfig.encodingOptions +
        " " +
        "-c:v " +
        _codecConfig.libraryName +
        " -r $outputRate " +
        outputPath;
  }
}

//"-filter_complex \"[0:v][1:v]${watermarkFilter.complexFilter},drawtext=fontfile='$fontPath':fontsize=90:x=20:y=20:text='Testing':enable='between(t\\,1\\,2)'\" " +
