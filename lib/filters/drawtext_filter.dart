import 'dart:ui';

enum VideoTextPosition {
  top,
  bottom,
}

extension VideoTextPositionExt on VideoTextPosition {
  String get boxPosition {
    switch (this) {
      case VideoTextPosition.top:
        return 'ih-ih';

      case VideoTextPosition.bottom:
        return 'ih-h';
    }

    return 'ih-h';
  }

  String get textPosition {
    switch (this) {
      case VideoTextPosition.top:
        return 'x=(w-text_w)/2:y=0';

      case VideoTextPosition.bottom:
        return 'x=(w-text_w)/2:y=h-th';
    }

    return 'x=(w-text_w)/2:y=h-th';
  }
}

class DrawTextFilter {
  final String text;
  final int fontSize;
  final bool hasBox;
  final Color boxColor;
  final Color textColor;
  final int startTimeInSeconds;
  final int endTimeInSeconds;
  final VideoTextPosition textPosition;

  const DrawTextFilter({
    this.text,
    this.fontSize,
    this.hasBox,
    this.boxColor,
    this.textColor,
    this.startTimeInSeconds,
    this.endTimeInSeconds,
    this.textPosition = VideoTextPosition.bottom,
  });
}
