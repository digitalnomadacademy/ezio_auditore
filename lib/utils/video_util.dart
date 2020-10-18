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
    return VideoInfo.fromMap(info, size);
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
    var width = _getWidthFromStreams(map['streams']);
    var height = _getHeightFromStreams(map['streams']);
    var rotation = _getRotationFromStreams(map['streams']);

    try {
      frameRate = double.parse(_getRealFrameRate(map['streams']));
    } catch (e) {}

    return VideoInfo(
      fileSize: size / 1000.0,
      duration: map['duration'] as int,
      width: width, //map['streams'][0]['width'] as int,
      height: height, //map['streams'][0]['height'] as int,
      isVertical: (rotation == "90" || rotation == "270") ? true : false,
      bitrate: _getBitrateFromStreams(map['streams']),
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

  static int _getWidthFromStreams(List streams) {
    for (var i = 0; i < streams.length; i++) {
      if (streams[i]['width'] != null) return streams[i]['width'];
    }

    return 0;
  }

  static int _getHeightFromStreams(List streams) {
    for (var i = 0; i < streams.length; i++) {
      if (streams[i]['height'] != null) return streams[i]['height'];
    }

    return 0;
  }

  static int _getBitrateFromStreams(List streams) {
    for (var i = 0; i < streams.length; i++) {
      if (streams[i]['bitrate'] != null) return streams[i]['bitrate'];
    }

    return 0;
  }

  static String _getRotationFromStreams(List streams) {
    for (var i = 0; i < streams.length; i++) {
      if (streams[i]['metadata']['rotate'] != null)
        return streams[i]['metadata']['rotate'];
    }

    return "-1";
  }

  static String _getRealFrameRate(List streams) {
    for (var i = 0; i < streams.length; i++) {
      if (streams[i]['realFrameRate'] != null)
        return streams[i]['realFrameRate'];
    }

    return "0";
  }
}
