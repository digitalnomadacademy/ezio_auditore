import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_editor/codecs.dart';
import 'package:flutter_video_editor/flutter_video_editor.dart';
import 'package:flutter_video_editor/video_util.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExamplePage(),
    );
  }
}

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
                final tempPath = '${tempDir.path}/temp.mp4';

                Stopwatch stopwatch = Stopwatch()..start();

                final result = await videoEditor.encodeVideo(
                    videoPath: videoPath,
                    codec: Codec.x264,
                    outputPath: tempPath);

                var message = '';
                if (result == VideoOutputState.success) {
                  message = 'Encoding success';
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
