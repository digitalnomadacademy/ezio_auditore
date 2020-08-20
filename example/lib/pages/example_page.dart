import 'dart:io';
import 'package:flutter_video_editor/filters/drawtext_filter.dart';
import 'package:flutter_video_editor/filters/watermark_filter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/flutter_video_editor.dart';
import 'package:flutter_video_editor/utils/video_util.dart';
import 'package:flutter_video_editor/constants/presets.dart';
import 'package:path_provider/path_provider.dart';

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  var fileName = '';
  var videoPath = '';
  var encodeMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(fileName),
            FlatButton(
              child: Text('Pick video'),
              onPressed: () async {
                File video = await FilePicker.getFile(
                    type: FileType.custom, allowedExtensions: [".mp4"]);

                setState(() {
                  fileName = video.path;
                  videoPath = video.path;
                });
              },
            ),
            FlatButton(
              child: Text('Encode'),
              onPressed: () async {
                final videoEditor = VideoEditor();

                //Get temp file path
                var tempDir = await getTemporaryDirectory();
                final tempPath =
                    '${tempDir.path}/${DateTime.now().toIso8601String()}.mp4';

                //Watermark
                final watermark = await getWaterMarkPath();

                //Text Filters
                final textFilters = [
                  DrawTextFilter(
                    text: "This is a text",
                    boxColor: Colors.black,
                    fontSize: 45,
                    hasBox: true,
                    startTimeInSeconds: 1,
                    endTimeInSeconds: 3,
                    textPosition: VideoTextPosition.top,
                  )
                ];

                Stopwatch stopwatch = Stopwatch()..start();
                final result = await videoEditor.encodeVideo(
                  videoPath: videoPath,
                  codec: VideoCodec.x264,
                  outputPath: tempPath,
                  watermark: watermark,
                  textFilters: textFilters,
                  watermarkPosition: WatermarkPosition.topRight,
                  preset: Preset.veryFast,
                );

                var message = '';
                if (result == VideoOutputState.success) {
                  message = 'Encoding success';
                  await GallerySaver.saveVideo(tempPath,
                          albumName: "FlutterVideoEditor")
                      .then((value) => debugPrint("saved $value"));
                } else {
                  message = 'Encoding failed with result code: $result';
                }
                setState(() {
                  encodeMessage = message +
                      "\nEncode time : ${stopwatch.elapsed.inSeconds} seconds";
                });
              },
            ),
            FlatButton(
              child: Text('Get Media Info'),
              onPressed: () async {
                final util = VideoUtil();
                final result = await util.getVideoInfo(videoPath);
                print(result);
              },
            ),
            Text(encodeMessage),
          ],
        ),
      ),
    );
  }
}

Future<String> getWaterMarkPath() async {
  //final byteData = await rootBundle.load(path);
  final tempPath = await getApplicationDocumentsDirectory();
  final imageFile = File('${tempPath.path}/watermark.png');

  // call http.get method and pass imageUrl into it to get response.
  http.Response response = await http.get(
      "https://bs-uploads.toptal.io/blackfish-uploads/components/skill_page/content/logo_file/logo/195440/Fluttter-7ff47f876b336e2b830c4a76821aadc7-d808d707c63ad949e71143232feca1de.png");

  await imageFile.writeAsBytes(response.bodyBytes);

  return imageFile.path;
}
