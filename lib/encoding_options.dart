import 'package:flutter_video_editor/constants/presets.dart';

/// Helper class to generate encoding options string for ffmpeg
class EncodingOptions {
  /// Represents the Constant Rate Factor (CRF) +- 6 adds a noticeable difference
  /// in file size and quality. Lower value leads to higher quality and greater file size
  /// Defaults to 27
  final int crf;

  /// Preset to decide encoding speed. Defaults to medium
  final Preset preset;

  const EncodingOptions({
    this.crf = 27,
    this.preset = Preset.defaultPreset,
  }) : assert(crf != null && preset != null);

  /// Outputs a [String] to be used in ffmpeg encode command
  String generate() {
    return '-crf $crf -preset ${preset.name} ';
  }
}
