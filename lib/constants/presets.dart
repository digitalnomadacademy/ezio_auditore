/// As per ffmpeg documentation
/// The default is medium. The preset determines how fast the encoding process will be at the expense of detail.
/// Put differently, if you choose ultrafast, the encoding process is going to run fast, and the file size will be smaller
/// when compared to medium.
/// The visual quality will not be as good. Slower presets use more memory.
///
/// If you intend on using preset names call the extension [.name] on preset enum

enum Preset {
  ultraFast,
  superFast,
  veryFast,
  faster,
  fast,
  medium,
  slow,
  slower,
  verySlow,
  placebo,
  defaultPreset,
}

extension PresetNames on Preset {
  String get name {
    switch (this) {
      case Preset.ultraFast:
        return 'ultrafast';

      case Preset.superFast:
        return 'superfast';

      case Preset.veryFast:
        return 'veryfast';

      case Preset.faster:
        return 'faster';

      case Preset.fast:
        return 'fast';

      case Preset.medium:
        return 'medium';

      case Preset.slow:
        return 'slow';

      case Preset.slower:
        return 'slower';

      case Preset.verySlow:
        return 'veryslow';

      case Preset.placebo:
        return 'palcebo';

      case Preset.defaultPreset:
        return 'medium';
    }

    return 'medium';
  }
}
