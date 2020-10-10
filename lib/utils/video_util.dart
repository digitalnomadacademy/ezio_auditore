import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import '../codecs.dart';

class VideoUtil {
  final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();

  Future<VideoInfo> getVideoInfo(String path) async {
    final info = await _flutterFFprobe.getMediaInformation(path);
    final tmpFile = File(path);
    var size = await tmpFile.length();
    return VideoInfo.fromMap(info.getAllProperties(), size);
  }
}

class VideoInfo {
  final int width;
  final int height;
  final int bitrate;
  final int duration;
  final VideoCodec codec;
  final bool isVertical;
  final double frameRate;
  final double fileSize;

  int get rotatedHeight => isVertical ? width : height;
  int get rotatedWidth => isVertical ? height : width;

  int get totalPixels => width * height;

  const VideoInfo({
    @required this.width,
    @required this.height,
    @required this.bitrate,
    @required this.duration,
    @required this.codec,
    @required this.frameRate,
    @required this.isVertical,
    @required this.fileSize,
  });

  factory VideoInfo.fromMap(Map<dynamic, dynamic> map, size) {
    debugPrint(map.toString());

    var frameRate = 0.0;
    final width = map['streams'][0]['width'] as int;
    final height = map['streams'][0]['height'] as int;

    try {
      frameRate = double.parse(map['streams'][0]['realFrameRate']);
    } catch (e) {}

    return VideoInfo(
      fileSize: size / 1000.0,
      duration: double.parse(map['format']['duration'] as String).floor(),
      width: width,
      height: height,
      isVertical: (height > width) ? true : false,
      bitrate: map['streams'][0]['bitrate'] as int,
      codec:
          map['streams'][0]['codec'].toString().toLowerCase().contains('h264')
              ? VideoCodec.x264
              : VideoCodec.x265,
      frameRate: frameRate,
    );
  }

  @override
  String toString() {
    return 'Info{width: $width, height: $height, bitrate: $bitrate, duration: $duration, codec: $codec, isVertical: $isVertical, frameRate: $frameRate, fileSize: $fileSize}';
  }
}
