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
