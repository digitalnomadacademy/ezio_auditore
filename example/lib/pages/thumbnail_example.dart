import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_editor/thumbnails/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailExample extends StatefulWidget {
  @override
  _ThumbnailExampleState createState() => _ThumbnailExampleState();
}

class _ThumbnailExampleState extends State<ThumbnailExample> {
  String videoPath = "";
  String thumbnailPath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
            ),
            SizedBox(
              height: 140,
            ),
            Text(videoPath.split('/').last),
            FlatButton(
              child: Text('Pick video'),
              onPressed: () async {
                File video = await FilePicker.getFile(
                  type: FileType.video,
                );

                var tempDir = await getApplicationDocumentsDirectory();

                final outputPath = '${tempDir.path}/';

                thumbnailPath = await VideoThumbnail().getThumbnailForVideo(
                    videoPath: video.path, outputPath: outputPath);

                setState(() {
                  videoPath = video.path;
                });
              },
            ),
            SizedBox(
              height: 32,
            ),
            if (thumbnailPath.isNotEmpty)
              Image.file(
                File(thumbnailPath),
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
          ],
        ),
      ),
    );
  }
}
