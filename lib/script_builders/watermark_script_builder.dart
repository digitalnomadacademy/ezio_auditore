import 'package:flutter_video_editor/watermark_filter.dart';

class WatermarkScriptBuilder {
  final String watermark;
  final WatermarkPosition watermarkPosition;
  final bool withFilter;

  WatermarkScriptBuilder(
      {this.watermark, this.watermarkPosition, this.withFilter = true});

  /// Takes absolute path of watermark and returns ffmpeg input and filter params
  WatermarkFiler build() {
    if (watermark.isNotEmpty) {
      // Sets overlay to bottom right corner of screen

      var complexFilter =
          '-filter_complex \'${watermarkPosition.overlayFilterString}\' ';

      if (!withFilter) {
        complexFilter = '${watermarkPosition.overlayFilterString} ';
      }

      return WatermarkFiler(
          input: '-i $watermark ', complexFilter: complexFilter);
    }

    return WatermarkFiler();
  }
}
