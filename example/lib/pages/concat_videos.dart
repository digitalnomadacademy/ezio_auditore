import 'dart:io';

import 'package:example/pages/example_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_editor/filters/drawtext_filter.dart';
import 'package:flutter_video_editor/filters/watermark_filter.dart';
import 'package:flutter_video_editor/utils/video_util.dart';
import 'package:flutter_video_editor/flutter_video_editor.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ConcatVideosPage extends StatefulWidget {
  @override
  _ConcatVideosPageState createState() => _ConcatVideosPageState();
}

class _ConcatVideosPageState extends State<ConcatVideosPage> {
  String video_1_path = "";
  var video_1;
  var video_2;
  String video_2_path = "";
  final VideoUtil videoUtil = VideoUtil();
  final VideoEditor videoEditor = VideoEditor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(video_1_path.split('/').last),
            FlatButton(
              child: Text('Pick video 1'),
              onPressed: () async {
                File video = await FilePicker.getFile(
                  type: FileType.video,
//                  allowedExtensions: [".mp4"],
                );
                final info = await videoUtil.getVideoInfo(video.path);
                setState(() {
                  video_1 = info;
                  video_1_path = video.path;
                });
              },
            ),
            Text(video_2_path.split('/').last),
            FlatButton(
              child: Text('Pick video 2'),
              onPressed: () async {
                File video = await FilePicker.getFile(
                  type: FileType.video,
                  //                  allowedExtensions: [".mp4"],
                );
                final info = await videoUtil.getVideoInfo(video.path);

                setState(() {
                  video_2 = info;

                  video_2_path = video.path;
                });
              },
            ),
            FlatButton(
              child: Text('Concat'),
              onPressed: () async {
                var tempDir = await getApplicationDocumentsDirectory();

                final tempPath =
                    '${tempDir.path}/${DateTime.now().toIso8601String()}.mp4';

                //Watermark
                final watermark = await getWaterMarkPath();

                //Text
                final List<DrawTextFilter> textFilters = [
                  DrawTextFilter(
                    text:
                        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec",
                    boxColor: Colors.black,
                    fontSize: 45,
                    hasBox: true,
                    startTimeInSeconds: 1,
                    endTimeInSeconds: 5,
                    textPosition: VideoTextPosition.top,
                  ),
                  DrawTextFilter(
                    text:
                        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec",
                    boxColor: Colors.black,
                    fontSize: 45,
                    hasBox: true,
                    startTimeInSeconds: 6,
                    endTimeInSeconds: 10,
                    textPosition: VideoTextPosition.bottom,
                  ),
                ];

                await videoEditor.combineVideos(
                    videoPaths: [video_1_path, video_2_path],
                    outputPath: tempPath,
                    watermark: watermark,
                    textFilters: textFilters,
                    watermarkPosition: WatermarkPosition.topLeft,
                    preset: Preset.superFast);
                await GallerySaver.saveVideo(tempPath,
                        albumName: "FlutterVideoEditor")
                    .then((value) => debugPrint("saved $value"));
              },
            )
          ],
        ),
      ),
    );
  }
}
