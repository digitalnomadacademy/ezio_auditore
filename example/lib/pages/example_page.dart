import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttervideoeditor/codecs.dart';
import 'package:fluttervideoeditor/fluttervideoeditor.dart';
import 'package:fluttervideoeditor/videoutil.dart';

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
              child: Text('Encode with hevc'),
              onPressed: () async {
                final videoEditor = VideoEditor();
                Stopwatch stopwatch = Stopwatch()..start();
                final result =
                    await videoEditor.encodeVideo(videoPath, VideoCodec.x264);

                var message = '';
                if (result == 0) {
                  message = 'Encoding success';
                } else {
                  message = 'Encoding failed with result code: $result';
                }

                setState(() {
                  encodeMessage = message +
                      "Encode time : ${stopwatch.elapsed.inMilliseconds}";
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
