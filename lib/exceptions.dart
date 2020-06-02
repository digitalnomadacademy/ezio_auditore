class InvalidArgumentException implements Exception {
  String msg;
  InvalidArgumentException(this.msg);
  String toString() => 'InvalidArgumentException: $msg';
}

class CodecMismatchException implements Exception {
  String msg;
  CodecMismatchException(this.msg);
  String toString() => 'CodecMismatchException: $msg';
}
