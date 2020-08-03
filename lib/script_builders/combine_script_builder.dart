import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:flutter_video_editor/script_builders/base_script_builder.dart';
import 'package:flutter_video_editor/script_builders/watermark_script_builder.dart';
import 'package:flutter_video_editor/filters/watermark_filter.dart';

class CombineScriptBuilder implements BaseScriptBuilder {
  final List<String> videoPaths;
  final String outputPath;
  final String fontPath;
  final CodecConfig codecConfig;
  final String watermark;
  final WatermarkPosition watermarkPosition;
  final VideoCodec codec;
  final int outputRate;
  final int crf;
  final Preset preset;

  const CombineScriptBuilder({
    this.videoPaths,
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

    var combineScript = '-y ';
    for (final path in videoPaths) {
      combineScript += '-i ' + path + ' ';
    }

    final watermarkFilter = WatermarkScriptBuilder(
            watermark: watermark,
            watermarkPosition: watermarkPosition,
            withFilter: false)
        .build();

    if (watermarkFilter.input.isNotEmpty) {
      combineScript += '${watermarkFilter.input} ';
    }

    combineScript += '-filter_complex "';
    var watermarkScript = '';
    if (watermarkFilter.complexFilter.isNotEmpty) {
      watermarkScript =
          "; [v][${videoPaths.length}:v]${watermarkFilter.complexFilter} ";
    }

    for (var i = 0; i < videoPaths.length; i++) {
      combineScript +=
          '[$i:v]scale=720:1280:force_original_aspect_ratio=0[v$i]; ';
    }

    for (var i = 0; i < videoPaths.length; i++) {
      combineScript += '[v$i][$i:a]';
    }

    if (watermarkScript.isNotEmpty) {
      combineScript +=
          'concat=unsafe=1:n=${videoPaths.length}:v=1:a=1 [v] [aout]$watermarkScript[vout]" -map [vout] -map [aout] ';
    } else {
      combineScript +=
          'concat=unsafe=1:n=${videoPaths.length}:v=1:a=1 [v] [a]" -map [v] -map [a] ';
    }
    combineScript += _codecConfig.encodingOptions + ' -vsync 2 -r $outputRate ';

    combineScript += outputPath;

    return combineScript;
  }
}
