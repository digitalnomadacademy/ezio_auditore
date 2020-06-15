class InvalidArgumentException implements Exception {
  String msg;
  InvalidArgumentException(this.msg);
  String toString() => 'InvalidArgumentException: $msg';
}

class NoCameraFoundException implements Exception {
  String msg;
  NoCameraFoundException(this.msg);
  String toString() => 'NoCameraFoundException: $msg';
}

class CodecMismatchException implements Exception {
  String msg;
  CodecMismatchException(this.msg);
  String toString() => 'CodecMismatchException: $msg';
}
