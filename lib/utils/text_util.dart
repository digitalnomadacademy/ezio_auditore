class ProcessedString {
  final List<String> tokens;
  final int scaledFontSize;

  ProcessedString(this.tokens, this.scaledFontSize);
}

class TextUtil {
  final String text;

  TextUtil(this.text);

  static const FONT_SIZE_REF = 24;
  static const WORDS_IN_LINE = 4;
  static const CHARS_IN_LINE = 27;
  static const MAX_LINES = 6;

  ProcessedString tokenize() {
    final words = text.split(' ');
    final numOfWords = words.length;
    final numOfChars = text.length;

    final charCountRatio = CHARS_IN_LINE * MAX_LINES;

    if (numOfChars > charCountRatio) {
      // Tokenize based on size ratio
      final ratio = numOfChars / charCountRatio;

      final scaledFont = ((1 / ratio) * FONT_SIZE_REF).floor();

      return ProcessedString(
          _baseTokens((ratio * CHARS_IN_LINE).floor()), scaledFont);
    } else {
      // Split normal text into tokens
      return ProcessedString(_baseTokens(CHARS_IN_LINE), FONT_SIZE_REF);
    }
  }

  List<String> _baseTokens(int charLength) {
    final textUnits = text.codeUnits;
    var parsedText = '';

    for (var i = 0; i < textUnits.length; i++) {
      if (i != 0 && i % charLength == 0) {
        if (String.fromCharCode(textUnits[i]) == ' ') {
          parsedText += '\n';
          continue;
        } else {
          parsedText += '${String.fromCharCode(textUnits[i])}-\n';
          continue;
        }
      }

      parsedText += String.fromCharCode(textUnits[i]);
    }

    return parsedText.split('\n');
  }
}
