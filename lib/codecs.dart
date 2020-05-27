enum Codec { x264, x265 }

class CodecConfig {
  final String libraryName;
  final String encodingOptions;

  const CodecConfig({
    this.libraryName,
    this.encodingOptions,
  });
}
