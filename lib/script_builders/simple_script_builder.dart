import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/filters/drawtext_filter.dart';
import 'package:flutter_video_editor/script_builders/base_script_builder.dart';
import 'package:flutter_video_editor/script_builders/drawtext_script_builder.dart';
import 'package:flutter_video_editor/script_builders/watermark_script_builder.dart';
import 'package:flutter_video_editor/filters/watermark_filter.dart';

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
  final List<DrawTextFilter> textFilters;

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
    this.textFilters = const [],
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

    final textFilterScript =
        DrawTextScriptBuilder(textFilters, fontPath).build();

    final filters = _filters(watermarkFilter, textFilterScript);

    /// For documentation regarding flags https://ffmpeg.org/ffmpeg.html#toc-Main-options
    return "-y -i " +
        videoPath +
        " " +
        filters +
        _codecConfig.encodingOptions +
        " " +
        "-c:v " +
        _codecConfig.libraryName +
        " -r $outputRate " +
        outputPath;
  }

  String _filters(WatermarkFiler watermarkFilter, String textFilterScript) {
    if (textFilterScript.isEmpty) {
      return watermarkFilter.input + watermarkFilter.complexFilter + " ";
    } else if (watermarkFilter.input.isNotEmpty &&
        textFilterScript.isNotEmpty) {
      return watermarkFilter.input +
          "-filter_complex \"[0:v][1:v]${watermarkFilter.complexFilter},$textFilterScript\" ";
    } else {
      // Only text filter needs to applied
      return "-filter_complex \"[0:v][1:v]$textFilterScript\" ";
    }
  }
}
