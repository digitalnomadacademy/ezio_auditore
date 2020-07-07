enum WatermarkPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

extension WatermarkPositionFilter on WatermarkPosition {
  String get overlayFilterString {
    switch (this) {
      case WatermarkPosition.topLeft:
        return '\'overlay=5:5\'';

      case WatermarkPosition.topRight:
        return '\'overlay=main_w-overlay_w-5:5\'';

      case WatermarkPosition.bottomLeft:
        return '\'overlay=5:main_h-overlay_h\'';

      case WatermarkPosition.bottomRight:
        return '\'overlay=main_w-overlay_w-5:main_h-overlay_h-5\'';
    }

    return '\'overlay=main_w-overlay_w-5:main_h-overlay_h-5\'';
  }
}

class WatermarkFiler {
  final String input;
  final String complexFilter;

  const WatermarkFiler({
    this.input = '',
    this.complexFilter = '',
  });
}
