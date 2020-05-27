import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttervideoeditor/codecs.dart';
import 'package:fluttervideoeditor/fluttervideoeditor.dart';

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
              child: Text('Encode with hevc'),
              onPressed: () async {
                final videoEditor = VideoEditor();
                final result =
                    await videoEditor.encodeVideo(videoPath, Codec.x265);

                var message = '';
                if (result == 0) {
                  message = 'Encoding success';
                } else {
                  message = 'Encoding failed with result code: $result';
                }

                setState(() {
                  encodeMessage = message;
                });
              },
            ),
            Text(encodeMessage),
          ],
        ),
      ),
    );
  }
}
