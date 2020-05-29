enum Codec {
  x264, //Used to represent Advanced Video Coding (AVC), also referred to as H.264 or MPEG-4
  x265, //Used to represent High Efficiency Video Coding (HEVC), also known as H.265 and MPEG-H Part 2
}

class CodecConfig {
  final String libraryName;
  final String encodingOptions;

  const CodecConfig({
    this.libraryName,
    this.encodingOptions,
  }) : assert(libraryName != null &&
            libraryName != '' &&
            encodingOptions != null);
}
