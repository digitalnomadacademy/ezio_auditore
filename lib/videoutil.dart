import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import 'codecs.dart';

class VideoUtil {
  final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();

  Future<Info> getVideoInfo(String path) async {
    final info = await _flutterFFprobe.getMediaInformation(path);
    final tmpFile = File(path);
    var size = await tmpFile.length();
    return Info.fromMap(info, size);
  }
}

class Info {
  final int width, height, bitrate, duration;
  final Codec codec;
  final bool isVertical;
  final double framerate, filesize;
  const Info({
    @required this.width,
    @required this.height,
    @required this.bitrate,
    @required this.duration,
    @required this.codec,
    @required this.framerate,
    @required this.isVertical,
    @required this.filesize,
  });

  factory Info.fromMap(Map<dynamic, dynamic> map, size) {
    debugPrint(map.toString());
    return Info(
      filesize: size / 1000.0,
      duration: map['duration'] as int,
      width: map['streams'][0]['width'] as int,
      height: map['streams'][0]['height'] as int,
      isVertical:
          map['streams'][0]['metadata']['rotate'] == "90" ? true : false,
      bitrate: map['streams'][0]['bitrate'] as int,
      codec:
          map['streams'][0]['codec'].toString().toLowerCase().contains('h264')
              ? Codec.x264
              : Codec.x265,
      framerate: double.parse(map['streams'][0]['realFrameRate']),
    );
  }

  @override
  String toString() {
    return 'Info{width: $width, height: $height, bitrate: $bitrate, duration: $duration, codec: $codec, isVertical: $isVertical, framerate: $framerate, filesize: $filesize}';
  }
}
