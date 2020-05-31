class InvalidArgumentException implements Exception {
  String msg;
  InvalidArgumentException(this.msg);
  String toString() => 'InvalidArgumentException: $msg';
}
