import 'package:string_validator/string_validator.dart';

class ProcessedString {
  final List<String> tokens;
  final int scaledFontSize;

  ProcessedString(this.tokens, this.scaledFontSize);
}

class TextUtil {
  final String text;

  TextUtil(this.text);

  static const FONT_SIZE_REF = (24 * 3);
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
      return ProcessedString(_baseTokens(CHARS_IN_LINE), FONT_SIZE_REF.floor());
    }
  }

  List<String> _baseTokens(int charLength) {
    final textUnits = text.codeUnits;
    var parsedText = '';
    var checkAdjustment = 0;
    var nextCharAdded = false;

    for (var i = 0; i < textUnits.length; i++) {
      if (i != 0 && (i - checkAdjustment) % charLength == 0) {
        if (String.fromCharCode(textUnits[i]) == ' ') {
          parsedText += '\n';
          checkAdjustment = 0;
          continue;
        } else {
          //Check if next character is not alpha then continue
          final char = String.fromCharCode(textUnits[i]);
          final hasAnotherChar = i + 1 < textUnits.length;

          if (isAlpha(char)) {
            if (hasAnotherChar) {
              final nextChar = String.fromCharCode(textUnits[i + 1]);
              if (!isAlpha(nextChar)) {
                parsedText += "$char$nextChar";
                checkAdjustment = 1;
                continue;
              }
            }
          } else {
            if (hasAnotherChar) {
              if (String.fromCharCode(textUnits[i + 1]) == ' ') {
                parsedText += '\n';
                checkAdjustment = 0;
                continue;
              }
            }
          }

          //Check if its a two letter word by comparing next three characters
          if (hasAnotherChar) {
            final nextChar = String.fromCharCode(textUnits[i + 1]);

            if (i + 2 < textUnits.length) {
              if (String.fromCharCode(textUnits[i + 2]) == ' ' &&
                  (i + 2) % charLength != 0) {
                parsedText += '$char$nextChar\n';
                nextCharAdded = true;
                continue;
              } else if (!isAlpha(String.fromCharCode(textUnits[i + 2]))) {
                //We can join it
                parsedText += '$char$nextChar';
                nextCharAdded = true;
                continue;
              }
            } else {
              //This is the last char
              parsedText += '$char$nextChar';
              nextCharAdded = true;
              continue;
            }
          }
          // If so then continue
          parsedText += '$char-\n';
          checkAdjustment = 0;
          continue;
        }
      }

      if (!nextCharAdded) {
        parsedText += String.fromCharCode(textUnits[i]);
      }
      nextCharAdded = false;
    }

    return parsedText.split('\n');
  }
}
