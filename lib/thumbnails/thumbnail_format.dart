enum ThumbnailFormat {
  png,
  jpeg,
  jpg,
}

extension ThumbnailFormatExt on ThumbnailFormat {
  String get name {
    return this.toString().split('.').last;
  }
}
