import 'dart:ui';

enum TextPosition {
  top,
  bottom,
}

class DrawTextFilter {
  final String text;
  final double fontSize;
  final bool hasBox;
  final Color boxColor;
  final Color textColor;
  final int startTimeInSeconds;
  final int endTimeInSeconds;
  final TextPosition textPosition;

  const DrawTextFilter({
    this.text,
    this.fontSize,
    this.hasBox,
    this.boxColor,
    this.textColor,
    this.startTimeInSeconds,
    this.endTimeInSeconds,
    this.textPosition = TextPosition.bottom,
  });
}
